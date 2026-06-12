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
import OSLog
import RoomServices
import VISOR

// MARK: - BuildingLoaderError

public enum BuildingLoaderError: Error {
  case connectivity
  case noDataAvailable
}

// MARK: - BuildingLoader

@Stubbable
public protocol BuildingLoader {
  func fetch() async -> Result<[Building], BuildingLoaderError>
}

extension BuildingLoader {
  func fetch() async throws(BuildingLoaderError) -> [Building] {
    try await fetch().get()
  }
}
// MARK: - LiveGraphQLBuildingLoader

nonisolated public final class LiveGraphQLBuildingLoader: BuildingLoader, Sendable {

  // MARK: Lifecycle

  public init(
    client: ApolloClient,
    roomStatusLoader: any RoomStatusLoader,
    buildingRatingLoader: any BuildingRatingLoader,
    buildingsCache: (any BuildingsCache)?)
  {
    self.client = client
    self.roomStatusLoader = roomStatusLoader
    self.buildingRatingLoader = buildingRatingLoader
    self.buildingsCache = buildingsCache
  }

  // MARK: Public

  public func fetch() async -> Result<[Building], BuildingLoaderError> {
    // Check if we have a cache
    guard let buildingsCache else {
      return await _fetchBuildings_slowpath()
    }

    // Check if we can use the cache
    // TODO: Allow configuration of this value
    let oldestAllowedCache = Date() - (60 * 60 * 24)
    let lastUpdated: Date?
    var buildings: [Building]
    do {
      lastUpdated = try await buildingsCache.lastUpdated
      if let lastUpdated, lastUpdated > oldestAllowedCache {
        logger.trace("Fetching buildings from cache...")
        guard let cacheBuildings = try await buildingsCache.getBuildings() else {
          logger.debug("No buildings in cache, falling back to slowpath")
          return await _fetchBuildings_slowpath()
        }
        buildings = cacheBuildings
      } else {
        logger.debug("Cache is too old, falling back to slowpath")
        return await _fetchBuildings_slowpath()
      }
    } catch let error {
      logger.warning("Failed to load from cache, refetching buildings: \(error)")
      return await _fetchBuildings_slowpath()
    }

    // Get availability statuses for buildings
    // this is intentionally not cached
    logger.trace("Fetched buildings & ratings from cache")

    // Fetch the building statuses, this is not cached on purpose
    await _updateBuildingStatuses(&buildings)

    return .success(buildings)
  }

  // MARK: Internal

  let client: ApolloClient
  let roomStatusLoader: any RoomStatusLoader
  let buildingRatingLoader: any BuildingRatingLoader
  let buildingsCache: (any BuildingsCache)?

  // MARK: Private

  private static let logger = Logger(subsystem: "com.devsoc.Freerooms.Buildings", category: "LiveGraphQLBuildingLoader")

  private var logger: Logger { Self.logger }

  private func _fetchBuildings_slowpath() async -> Result<[Building], BuildingLoaderError> {
    // Fetch the buildings if required.
    // The buildings may be stored
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

    // Add ratings to builings, if available
    await _updateBuildingRatings(&buildings)

    // Save building results to cache
    if let buildingsCache {
      do {
        try await buildingsCache.setBuildings(buildings)
      } catch {
        logger.warning("Failed to save to cache")
      }
    }

    // Update buildings with their statuses, if they are available
    await _updateBuildingStatuses(&buildings)

    return .success(buildings)
  }

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
