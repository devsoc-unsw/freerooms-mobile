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
  /// From Networking
  case connectivity

  /// From SwiftData
  case persistenceError
  case noDataAvailable

  /// From JSONLoader
  case fileNotFound
  case malformedJSON
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

public class LiveBuildingLoader: BuildingLoader {

  // MARK: Lifecycle

  public init(
    swiftDataBuildingLoader: SwiftDataBuildingLoader,
    JSONBuildingLoader: JSONBuildingLoader,
    roomStatusLoader: RoomStatusLoader)
  {
    self.swiftDataBuildingLoader = swiftDataBuildingLoader
    self.JSONBuildingLoader = JSONBuildingLoader
    self.roomStatusLoader = roomStatusLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Building], BuildingLoaderError>

  public func fetch() async -> Result {
    if !hasSavedData {
      await seedLock.wait()
      defer { seedLock.signal() }

      if !hasSavedData {
        switch JSONBuildingLoader.fetch() {
        case .success(let offlineBuildings):
          if case .failure(let err) = swiftDataBuildingLoader.seed(offlineBuildings) {
            return .failure(err)
          }
          UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSavedBuildingsData)
          return await combineLiveAndOfflineData(offlineBuildings)

        case .failure(let err):
          return .failure(err)
        }
      }
    }

    switch swiftDataBuildingLoader.fetch() {
    case .success(let buildings):
      return .success(buildings)
    case .failure(let err):
      return .failure(err)
    }
  }

  // MARK: Private

  private let swiftDataBuildingLoader: SwiftDataBuildingLoader
  private let JSONBuildingLoader: JSONBuildingLoader
  private let roomStatusLoader: RoomStatusLoader

  /// Simple async lock
  private let seedLock = AsyncSemaphore()

  private var hasSavedData: Bool {
    UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData)
  }

  private func combineLiveAndOfflineData(_ offlineBuildings: [Building]) async -> Result {
    switch await roomStatusLoader.fetchRoomStatus() {
    case .success(let roomStatusResponse):
      let buildingsWithStatus = offlineBuildings.map { building in
        let buildingRoomStatus = roomStatusResponse[building.id]
        return Building(
          name: building.name,
          id: building.id,
          latitude: building.latitude,
          longitude: building.longitude,
          aliases: building.aliases,
          numberOfAvailableRooms: buildingRoomStatus?.numAvailable ?? building.numberOfAvailableRooms)
      }
      return .success(buildingsWithStatus)

    case .failure:
      return .success(offlineBuildings)
    }
  }

}

// MARK: - AsyncSemaphore

final class AsyncSemaphore {

  // MARK: Internal

  func wait() async {
    await withCheckedContinuation { continuation in
      if !isLocked {
        isLocked = true
        continuation.resume()
      } else {
        waiters.append(continuation)
      }
    }
  }

  func signal() {
    if let next = waiters.first {
      waiters.removeFirst()
      next.resume()
    } else {
      isLocked = false
    }
  }

  // MARK: Private

  private var isLocked = false
  private var waiters: [CheckedContinuation<Void, Never>] = []

}
