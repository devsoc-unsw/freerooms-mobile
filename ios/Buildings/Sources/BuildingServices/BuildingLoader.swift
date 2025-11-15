//
//  BuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import BuildingModels
import Foundation
import Networking
import Persistence
import RoomServices

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

public protocol BuildingLoader {
  func fetch() async -> Result<[Building], BuildingLoaderError>
}

// MARK: - RemoteBuildingLoader

public protocol RemoteBuildingLoader {
  func fetch() -> Result<[RemoteBuilding], BuildingLoaderError>
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
        offlineBuildings[i].numberOfAvailableRooms = await roomStatusResponse[offlineBuildings[i].id]?.numAvailable
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
