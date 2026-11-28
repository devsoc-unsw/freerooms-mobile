//
//  BuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

public import Apollo
public import BuildingModels
import DevSocAPI
public import Foundation
import OSLog
import RoomModels
public import RoomServices
import VISOR
public import VISORTestDoubles
public import Networking

// MARK: - BuildingLoaderError

public enum BuildingLoaderError: Error {
  case connectivity
  case noDataAvailable
}

// MARK: - BuildingLoader

@GenerateStub(.sendable)
public protocol BuildingLoader: Sendable {
  func fetch() async throws -> [Building]
}

// MARK: - LiveGraphQLBuildingLoader

public final actor LiveGraphQLBuildingLoader: BuildingLoader, Sendable {

  // MARK: Lifecycle

  public init(
    client: ApolloClient,
    session: any HTTPSession,
    baseURL: URL,
    roomStatusLoader: any RoomStatusLoader,
    buildingsCache: (any BuildingsCache)?)
  {
    self.client = client
    self.session = session
    self.roomRatingsEndpoint = baseURL.appending(component: "ratings")
    self.roomStatusLoader = roomStatusLoader
    self.buildingsCache = buildingsCache
  }

  // MARK: Public

  public func fetch() async throws -> [Building] {
    // Check if we have a cache
    guard let buildingsCache else {
      return try await _fetchBuildingsFromServer()
    }

    // Check if we can use the cache.
    let oldestAllowedCache = Date() - Self.cacheFreshnessInterval
    let lastUpdated: Date?
    var buildings: [Building]
    do {
      lastUpdated = try await buildingsCache.lastUpdated
      if let lastUpdated, lastUpdated > oldestAllowedCache {
        logger.trace("Fetching buildings from cache...")
        guard let cacheBuildings = try await buildingsCache.getBuildings() else {
          logger.debug("No buildings in cache, falling back to server")
          return try await _fetchBuildingsFromServer()
        }
        buildings = cacheBuildings
      } else {
        logger.debug("Cache is too old, falling back to server")
        return try await _fetchBuildingsFromServer()
      }
    } catch let error {
      logger.warning("Failed to load from cache, refetching buildings: \(error)")
      return try await _fetchBuildingsFromServer()
    }

    // Get availability statuses for buildings
    // this is intentionally not cached
    logger.trace("Fetched buildings & ratings from cache")

    // Fetch the building statuses, this is not cached on purpose
    await _updateBuildingStatuses(&buildings)

    return buildings
  }

  // MARK: Internal

  let client: ApolloClient
  let session: any HTTPSession
  let roomRatingsEndpoint: URL
  let roomStatusLoader: any RoomStatusLoader
  let buildingsCache: (any BuildingsCache)?

  // MARK: Private

  /// Buildings are mostly static, so one day keeps launch fast without letting stale metadata linger indefinitely.
  private static let cacheFreshnessInterval = secondsPerMinute * minutesPerHour * hoursPerDay
  private static let hoursPerDay: TimeInterval = 24
  private static let minutesPerHour: TimeInterval = 60
  private static let secondsPerMinute: TimeInterval = 60

  private static let logger = Logger(subsystem: "com.devsoc.Freerooms.Buildings", category: "LiveGraphQLBuildingLoader")

  private var logger: Logger { Self.logger }

  private func _fetchBuildingsFromServer() async throws -> [Building] {
    // Fetch the buildings if required.
    // The buildings may be stored
    logger.trace("Fetching buildings from GraphQL")
    let graphQLBuildings: [DevSocAPI.AllBuildingsQuery.Data.Building]
    do {
      let response = try await client.fetch(query: AllBuildingsQuery())
      guard let buildings = response.data?.buildings else {
        logger.error("Data for buildings is missing from GraphQL response")
        throw BuildingLoaderError.noDataAvailable
      }
      graphQLBuildings = buildings
    } catch {
      logger.warning("Could not fetch buildings from GraphQL: \(error)")
      throw BuildingLoaderError.connectivity
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

    return buildings
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
    await withTaskGroup(of: RemoteBuildingRatingResponse?.self) { group in
      // Get the rating for each building
      for building in buildings {
        // If the building rating is unavailable, we return nil
        group.addTask {
          do {
            
            // Fetch building ratings
            let (data, _) = try await self.session.data(from: self.roomRatingsEndpoint.appending(component: building.id))
            let rating = try DevSoc.jsonDecoder.decode(RemoteBuildingRatingResponse.self, from: data)

            return rating
          } catch {
            logger.trace("Failed to fetch building rating for building with ID: \(building.id)")
            return nil
          }
        }

        for await rating in group {
          guard let rating else {
            continue
          }
          assert(!ratingsByID.keys.contains(rating.buildingId), "Made two requests for building with ID: \(rating.buildingId)")
          ratingsByID[rating.buildingId] = rating.overallRating
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
