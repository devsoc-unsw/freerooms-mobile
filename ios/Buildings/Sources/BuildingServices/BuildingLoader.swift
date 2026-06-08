//
//  BuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Apollo
import BuildingModels
import DevSocAPI
import Foundation
import Networking
import OSLog
import Persistence
import RoomServices
import VISOR

// MARK: - BuildingLoaderError

public enum BuildingLoaderError: Error {
  case connectivity
  case persistenceError
  case noDataAvailable
  case fileNotFound
  case malformedJSON
  case alreadySeeded
}

// MARK: - BuildingLoader

@Stubbable
public protocol BuildingLoader {
  func fetch() async -> Result<[Building], BuildingLoaderError>
}

// MARK: - RemoteBuildingLoader

@Stubbable
@available(*, deprecated, renamed: "BuildingLoader")
public protocol RemoteBuildingLoader {
  func fetch() -> Result<[RemoteBuilding], BuildingLoaderError>
}

// MARK: - LiveGraphQLBuildingLoader

nonisolated public final class LiveGraphQLBuildingLoader: BuildingLoader, Sendable {

  // MARK: Lifecycle

  public init(
    client: ApolloClient,
    roomStatusLoader: any RoomStatusLoader,
    buildingRatingLoader: any BuildingRatingLoader)
  {
    self.client = client
    self.roomStatusLoader = roomStatusLoader
    self.buildingRatingLoader = buildingRatingLoader
  }

  // MARK: Public

  public func fetch() async -> Result<[Building], BuildingLoaderError> {
    // Fetch the buildings if required.
    // The buildings will likely be stored on the device inside the SQLCache
    // in the running application
    logger.trace("Fetching buildings from GraphQL")
    let graphQLBuildings: [DevSocAPI.AllBuildingsQuery.Data.Building]
    do {
      let response = try await client.fetch(query: AllBuildingsQuery())
      guard let buildings = response.data?.buildings else {
        logger.error("Data for buildings is missing from GraphQL response")
        return .failure(.noDataAvailable)
      }
      graphQLBuildings = buildings
    } catch {
      logger.warning("Could not fetch buildings from GraphQL: \(error)")
      return .failure(.connectivity)
    }

    // Turn the GraphQL buildings into useable buildings
    var buildings: [Building] = []
    buildings.reserveCapacity(graphQLBuildings.count)
    for gqlb in graphQLBuildings {
      guard let building = Building(from: gqlb) else {
        // TODO: How should be handle an invalid building?
        logger.debug("Invalid building \(gqlb.name), skipping")
        continue
      }
      buildings.append(building)
    }

    // Update buildings with their statuses, if they are available
    await _updateBuildingStatuses(&buildings)
    // Add ratings to builings, if available
    await _updateBuildingRatings(&buildings)

    return .success(buildings)
  }

  // MARK: Internal

  let client: ApolloClient
  let roomStatusLoader: any RoomStatusLoader
  let buildingRatingLoader: any BuildingRatingLoader

  // MARK: Private

  private static let logger = Logger(subsystem: "com.devsoc.Freerooms.Buildings", category: "LiveGraphQLBuildingLoader")

  private var logger: Logger { Self.logger }

  private func _updateBuildingStatuses(_ buildings: inout [Building]) async {
    logger.trace("Fetching building statuses...")
    let roomStatusLoader = roomStatusLoader
    let buildingStatusesResult = await roomStatusLoader.fetchRoomStatus()

    // Make sure that we get a success response
    guard case .success(let buildingStatuses) = buildingStatusesResult else {
      logger.warning("Failed to get building statuses from loader: \(String(reflecting: roomStatusLoader))")
      return
    }

    // Apply each of the found building statuses
    logger.trace("Applying found building statuses")
    for (i, building) in buildings.enumerated() {
      guard let status = buildingStatuses[building.id] else {
        continue
      }
      buildings[i].numberOfAvailableRooms = status.numAvailable
    }
  }

  private func _updateBuildingRatings(_ buildings: inout sending [Building]) async {
    let logger = logger
    // Most buildings would have ratings
    var ratingsByID = [Building.ID: Double]()
    ratingsByID.reserveCapacity(buildings.count)

    // Can fetch ratings concurrently
    logger.trace("Fetching building ratings...")
    let buildingRatingLoader = buildingRatingLoader
    await withTaskGroup(of: (String, Double)?.self) { group in
      // Get the rating for each building
      for building in buildings {
        // If the building rating is unavailable, we return nil
        group.addTask {
          do {
            let result = try await buildingRatingLoader.fetch(buildingID: building.id).get()
            return (building.id, result)
          } catch {
            logger.trace("Failed to fetch building rating for building with ID: \(building.id)")
            return nil
          }
        }

        for await pair in group {
          guard let (buildingID, rating) = pair else {
            continue
          }
          assert(!ratingsByID.keys.contains(buildingID), "Made two requests for building with ID: \(buildingID)")
          ratingsByID[buildingID] = rating
        }
      }
    }

    // Update buildings with available ratings
    for (i, building) in buildings.enumerated() {
      guard let rating = ratingsByID[building.id] else { continue }
      buildings[i].overallRating = rating
    }
  }

}

// MARK: - LiveBuildingLoader

public final class LiveBuildingLoader: BuildingLoader, Sendable {

  // MARK: Lifecycle

  public init(
    swiftDataBuildingLoader: SwiftDataBuildingLoader,
    JSONBuildingLoader: JSONBuildingLoader,
    roomStatusLoader: RoomStatusLoader,
    buildingRatingLoader: BuildingRatingLoader)
  {
    self.swiftDataBuildingLoader = swiftDataBuildingLoader
    self.JSONBuildingLoader = JSONBuildingLoader
    self.roomStatusLoader = roomStatusLoader
    self.buildingRatingLoader = buildingRatingLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Building], BuildingLoaderError>

  public func fetch() async -> Result {
    if !hasSavedData {
      switch await JSONBuildingLoader.fetch() {
      case .success(var offlineBuildings):
        if case .failure(let err) = await swiftDataBuildingLoader.seed(offlineBuildings) {
          return .failure(err)
        }
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSavedBuildingsData)
        await combineLiveAndOfflineData(&offlineBuildings)
        return .success(offlineBuildings)

      case .failure(let err):
        return .failure(err)
      }
    }
    switch swiftDataBuildingLoader.fetch() {
    case .success(var offlineBuildings):
      await combineLiveAndOfflineData(&offlineBuildings)
      return .success(offlineBuildings)

    case .failure(let err):
      return .failure(err)
    }
  }

  // MARK: Private

  private let swiftDataBuildingLoader: SwiftDataBuildingLoader
  private let JSONBuildingLoader: JSONBuildingLoader
  private let roomStatusLoader: RoomStatusLoader
  private let buildingRatingLoader: BuildingRatingLoader

  private var hasSavedData: Bool {
    UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData)
  }

  @concurrent
  private func combineLiveAndOfflineData(_ offlineBuildings: inout [Building]) async {
    if case .success(let roomStatusResponse) = await roomStatusLoader.fetchRoomStatus() {
      for i in offlineBuildings.indices {
        offlineBuildings[i].numberOfAvailableRooms = roomStatusResponse[offlineBuildings[i].id]?.numAvailable
      }
    }

    let buildingIDs = offlineBuildings.map(\.id)

    let ratings = await withTaskGroup { group in
      for (index, buildingID) in buildingIDs.enumerated() {
        group.addTask { [buildingRatingLoader] in
          let res = await buildingRatingLoader.fetch(buildingID: buildingID)
          return (index, res)
        }
      }

      var ratings = [(Int, Swift.Result<Double, BuildingRatingLoaderError>)]()
      for await res in group {
        ratings.append(res)
      }

      ratings.sort { $0.0 < $1.0 }
      return ratings
    }

    let unwrappedRatings: [Double?] = ratings.map {
      switch $0.1 {
      case .success(let rating):
        rating
      case .failure:
        nil
      }
    }
    for (i, rating) in zip(offlineBuildings.indices, unwrappedRatings) {
      offlineBuildings[i].overallRating = rating
    }
  }

}
