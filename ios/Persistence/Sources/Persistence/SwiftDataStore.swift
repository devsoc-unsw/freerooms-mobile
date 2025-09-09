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
  public init(modelContext: ModelContext) throws {
    self.modelContext = modelContext
  }

  // MARK: Public

  public func deleteAll() throws {
    try modelContext.delete(model: Self.Model)
  }

  /// Saves a single item to the persistent store.
  public func save(_ item: Model) throws {
    modelContext.insert(item)
    try modelContext.save()
  }

  /// Saves multiple items to the persistent store; changes are only committed to backing store if all items successfully save.
  public func save(_ items: [Model]) throws {
    for item in items { modelContext.insert(item) }
    try modelContext.save()
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

  /// Deletes multiple items from the persistent store; changes are only committed to backing store if all items are successfully deleted.
  public func delete(_ items: [Model]) throws {
    for item in items { modelContext.delete(item) }
    try modelContext.save()
  }

  /// Fetches the amount of entries in the persistent store
  public func size() throws -> Int {
    let descriptor = FetchDescriptor<Model>()
    return try modelContext.fetchCount(descriptor)
  }

  // MARK: Private

  private let modelContext: ModelContext
}
