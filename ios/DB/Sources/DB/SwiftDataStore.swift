//
//  SwiftDataStore.swift
//  DB
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

import Foundation
import SwiftData

// MARK: - SwiftDataStore

/// A concrete implementation of the PersistentStore protocol using SwiftData.
/// Manages the model container and handles all persistence operations.
public final class SwiftDataStore: PersistentStore {

  // MARK: Lifecycle

  /// Initializes the SwiftData stack with model schema and configuration.
  public init() throws {
    let schema = Schema([
      BuildingModel.self,
      RoomModel.self,
    ])

    let modelConfiguration = ModelConfiguration(schema: schema)
    modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    modelContext = ModelContext(modelContainer)
  }

  // MARK: Public

  /// Saves a single item to the persistent store.
  public func save(_ item: some PersistentModel) throws {
    if let building = item as? BuildingModel {
      modelContext.insert(building)
      try modelContext.save()
    } else if let room = item as? RoomModel {
      modelContext.insert(room)
      try modelContext.save()
    } else {
      throw PersistentStoreError.invalidModelType
    }
  }

  /// Saves multiple items to the persistent store.
  public func save(_ items: [some PersistentModel]) throws {
    for item in items {
      try save(item)
    }
  }

  /// Fetches all items of a specific model type.
  public func fetch<T: PersistentModel>() throws -> [T] {
    if T.self == BuildingModel.self {
      let descriptor = FetchDescriptor<BuildingModel>()
      let results = try modelContext.fetch(descriptor)
      guard let typedResults = results as? [T] else {
        throw PersistentStoreError.typeCastFailure
      }
      return typedResults
    } else if T.self == RoomModel.self {
      let descriptor = FetchDescriptor<RoomModel>()
      let results = try modelContext.fetch(descriptor)
      guard let typedResults = results as? [T] else {
        throw PersistentStoreError.typeCastFailure
      }
      return typedResults
    } else {
      throw PersistentStoreError.unregisteredModelType
    }
  }

  /// Fetches a specific item by its unique identifier.
  public func fetch<T: PersistentModel>(id: String) throws -> T? {
    if T.self == BuildingModel.self {
      let descriptor = FetchDescriptor<BuildingModel>(
        predicate: #Predicate<BuildingModel> { $0.id == id })
      let result = try modelContext.fetch(descriptor).first
      return result as? T
    } else if T.self == RoomModel.self {
      let descriptor = FetchDescriptor<RoomModel>(
        predicate: #Predicate<RoomModel> { $0.id == id })
      let result = try modelContext.fetch(descriptor).first
      return result as? T
    } else {
      throw PersistentStoreError.unregisteredModelType
    }
  }

  /// Deletes a single item from the persistent store.
  public func delete(_ item: some PersistentModel) throws {
    if let building = item as? BuildingModel {
      modelContext.delete(building)
      try modelContext.save()
    } else if let room = item as? RoomModel {
      modelContext.delete(room)
      try modelContext.save()
    } else {
      throw PersistentStoreError.invalidModelType
    }
  }

  /// Deletes multiple items from the persistent store.
  public func delete(_ items: [some PersistentModel]) throws {
    for item in items {
      try delete(item)
    }
  }

  // MARK: Private

  private let modelContainer: ModelContainer
  private let modelContext: ModelContext
}

// MARK: - PersistentStoreError

/// Errors that can occur during persistent store operations.
public enum PersistentStoreError: Error {
  case invalidModelType
  case unregisteredModelType
  case typeCastFailure
}
