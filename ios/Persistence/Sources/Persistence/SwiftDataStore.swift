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
/// Generic over a single model type that conforms to PersistentModel and IdentifiableModel.
public final class SwiftDataStore<Model: PersistentModel & IdentifiableModel>: PersistentStore {

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
  public func save(_ item: Model) throws {
    modelContext.insert(item)
    try modelContext.save()
  }

  /// Saves multiple items to the persistent store.
  public func save(_ items: [Model]) throws {
    for item in items {
      try save(item)
    }
  }

  /// Fetches all items of the model type.
  public func fetchAll() throws -> [Model] {
    let descriptor = FetchDescriptor<Model>()
    return try modelContext.fetch(descriptor)
  }

  /// Fetches a specific item by its unique identifier.
  public func fetch(id: String) throws -> Model? {
    let descriptor = FetchDescriptor<Model>(
      predicate: #Predicate { $0.stringID == id })
    return try modelContext.fetch(descriptor).first
  }

  /// Deletes a single item from the persistent store.
  public func delete(_ item: Model) throws {
    modelContext.delete(item)
    try modelContext.save()
  }

  /// Deletes multiple items from the persistent store.
  public func delete(_ items: [Model]) throws {
    for item in items {
      try delete(item)
    }
  }

  // MARK: Private

  private let modelContainer: ModelContainer
  private let modelContext: ModelContext
}
