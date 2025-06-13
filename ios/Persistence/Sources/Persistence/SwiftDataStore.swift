//
//  SwiftDataStore.swift
//  Persistence
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

import Foundation
import SwiftData

// MARK: - SwiftDataStore

/// A concrete implementation of the PersistentStore protocol using SwiftData.
/// Manages the model container and handles all persistence operations.
/// Generic over a single model type that conforms to PersistentModel.
public final class SwiftDataStore<Model: PersistentModel>: PersistentStore {

  // MARK: Lifecycle

  /// Initializes the SwiftData stack with model schema and configuration.
  public init() throws {
    let schema = Schema([Model.self])
    let modelConfiguration = ModelConfiguration(schema: schema)
    modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    modelContext = ModelContext(modelContainer)
  }

  // MARK: Public

  /// Saves a single item to the persistent store.
  public func save(_ item: some PersistentModel) throws {
    guard let typedItem = item as? Model else {
      throw PersistentStoreError.invalidModelType
    }
    modelContext.insert(typedItem)
    try modelContext.save()
  }

  /// Saves multiple items to the persistent store.
  public func save(_ items: [some PersistentModel]) throws {
    for item in items {
      try save(item)
    }
  }

  /// Fetches all items of the model type.
  public func fetch<T: PersistentModel>() throws -> [T] {
    guard T.self == Model.self else {
      throw PersistentStoreError.unregisteredModelType
    }
    let descriptor = FetchDescriptor<Model>()
    let results = try modelContext.fetch(descriptor)
    guard let typedResults = results as? [T] else {
      throw PersistentStoreError.typeCastFailure
    }
    return typedResults
  }

  /// Fetches a specific item by its unique identifier.
  public func fetch<T: PersistentModel>(id: String) throws -> T? {
    guard T.self == Model.self else {
      throw PersistentStoreError.unregisteredModelType
    }
    let descriptor = FetchDescriptor<Model>(
      predicate: #Predicate<Model> { $0.id == id })
    let result = try modelContext.fetch(descriptor).first
    return result as? T
  }

  /// Deletes a single item from the persistent store.
  public func delete(_ item: some PersistentModel) throws {
    guard let typedItem = item as? Model else {
      throw PersistentStoreError.invalidModelType
    }
    modelContext.delete(typedItem)
    try modelContext.save()
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
