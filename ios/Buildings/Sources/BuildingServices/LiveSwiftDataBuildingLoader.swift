//
//  SwiftDataBuildingLoader.swift
//  Buildings
//
//  Created by Muqueet Mohsen Chowdhury on 29/6/2025.
//

import BuildingModels
import Foundation
import Persistence

// MARK: - SwiftDataBuildingLoader

public final class SwiftDataBuildingLoader: BuildingLoader {

  // MARK: Lifecycle

  public init(swiftDataStore: some PersistentStore<SwiftDataBuilding>) {
    self.swiftDataStore = swiftDataStore
  }
  
  public func seed(buildings: [Building]) async -> Result<Void, BuildingLoaderError> {
    do {
      try swiftDataStore.save(buildings.map {
        SwiftDataBuilding(name: $0.name, id: $0.id, latitude: $0.latitude, longitude: $0.longitude, aliases: $0.aliases, numberOfAvailableRooms: $0.numberOfAvailableRooms, rooms: [])
      })
      return .success(())
    } catch  {
      return .failure(.persistenceError)
    }
  }

  // MARK: Public

  public func fetch() async -> Result<[Building], BuildingLoaderError> {
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
