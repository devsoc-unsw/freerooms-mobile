//
//  SwiftDataBuildingLoader.swift
//  Buildings
//
//  Created by Muqueet Mohsen Chowdhury on 29/6/2025.
//

import Foundation
import Persistence

// MARK: - SwiftDataBuildingLoader

public final class SwiftDataBuildingLoader: BuildingLoader {

  // MARK: Lifecycle

  public init(swiftDataStore: some PersistentStore<SwiftDataBuilding>) {
    self.swiftDataStore = swiftDataStore
  }

  // MARK: Public

  public func fetch() async -> Result<[Building], Error> {
    do {
      let swiftDataBuildings = try swiftDataStore.fetchAll()

      if swiftDataBuildings.isEmpty {
        return .failure(BuildingLoaderError.noDataAvailable)
      }

      let buildings = swiftDataBuildings.map { $0.toBuilding() }
      return .success(buildings)

    } catch {
      return .failure(BuildingLoaderError.persistenceError)
    }
  }

  // MARK: Private

  private let swiftDataStore: any PersistentStore<SwiftDataBuilding>
}
