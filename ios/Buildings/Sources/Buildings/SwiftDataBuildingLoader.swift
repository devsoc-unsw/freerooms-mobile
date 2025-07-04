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

  public init<Store: PersistentStore>(swiftDataStore: Store) where Store.Model == SwiftDataBuilding {
    self.swiftDataStore = AnyPersistentStore(swiftDataStore)
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

  private let swiftDataStore: AnyPersistentStore<SwiftDataBuilding>
}

// MARK: - AnyPersistentStore

private struct AnyPersistentStore<Model>: PersistentStore {

  // MARK: Lifecycle

  init<Store: PersistentStore>(_ store: Store) where Store.Model == Model {
    _save = store.save
    _saveMultiple = store.save
    _fetchAll = store.fetchAll
    _fetch = store.fetch
    _delete = store.delete
    _deleteMultiple = store.delete
  }

  // MARK: Internal

  func save(_ item: Model) throws {
    try _save(item)
  }

  func save(_ items: [Model]) throws {
    try _saveMultiple(items)
  }

  func fetchAll() throws -> [Model] {
    try _fetchAll()
  }

  func fetch(id: String) throws -> Model? {
    try _fetch(id)
  }

  func delete(_ item: Model) throws {
    try _delete(item)
  }

  func delete(_ items: [Model]) throws {
    try _deleteMultiple(items)
  }

  // MARK: Private

  private let _save: (Model) throws -> Void
  private let _saveMultiple: ([Model]) throws -> Void
  private let _fetchAll: () throws -> [Model]
  private let _fetch: (String) throws -> Model?
  private let _delete: (Model) throws -> Void
  private let _deleteMultiple: ([Model]) throws -> Void

}
