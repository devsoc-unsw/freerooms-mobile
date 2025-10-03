//
//  LiveSwiftDataBuildingLoader.swift
//  Buildings
//
//  Created by Muqueet Mohsen Chowdhury on 29/6/2025.
//

import BuildingModels
import Foundation
import Persistence

// MARK: - SwiftDataBuildingLoader

@MainActor
public protocol SwiftDataBuildingLoader: Sendable {
  func fetch() -> Result<[Building], BuildingLoaderError>
  func seed(_ buildings: [Building]) async -> Result<Void, BuildingLoaderError>
}

// MARK: - LiveSwiftDataBuildingLoader

public final class LiveSwiftDataBuildingLoader: SwiftDataBuildingLoader {

  // MARK: Lifecycle

  public init(swiftDataStore: some PersistentStore<SwiftDataBuilding>) {
    self.swiftDataStore = swiftDataStore
  }

  // MARK: Public

  public func seed(_ buildings: [Building]) async -> Result<Void, BuildingLoaderError> {
    do {
      /// Ensure seed is only run once
      guard try swiftDataStore.size() == 0 else {
        return .failure(.alreadySeeded)
      }

      try swiftDataStore.save(buildings.map {
        SwiftDataBuilding(
          name: $0.name,
          id: $0.id,
          latitude: $0.latitude,
          longitude: $0.longitude,
          aliases: $0.aliases,
          numberOfAvailableRooms: $0.numberOfAvailableRooms)
      })
      return .success(())
    } catch {
      return .failure(.persistenceError)
    }
  }

  public func fetch() -> Result<[Building], BuildingLoaderError> {
    do {
      let swiftDataBuildings = try swiftDataStore.fetchAll()

      if swiftDataBuildings.isEmpty {
        return .failure(.noDataAvailable)
      }

      let buildings = swiftDataBuildings.map { $0.toBuilding() }
      return .success(buildings)

    } catch {
      return .failure(.persistenceError)
    }
  }

  // MARK: Private

  private let swiftDataStore: any PersistentStore<SwiftDataBuilding>
}
