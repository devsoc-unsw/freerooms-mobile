//
//  PersistentStore.swift
//  Persistence
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

// MARK: - PersistentStore

/// Defines an interface for saving, retrieving, and deleting persistent data.
public protocol PersistentStore {
  associatedtype Model
  /// Saves a single item.
  func save(_ item: Model) throws

  /// Saves multiple items.
  func save(_ items: [Model]) throws

  /// Fetches all items of a given type.
  func fetchAll() throws -> [Model]

  /// Fetches a single item by ID.
  func fetch(id: String) throws -> Model?

  /// Deletes a single item.
  func delete(_ item: Model) throws

  /// Deletes multiple items.
  func delete(_ items: [Model]) throws
}

// MARK: - IdentifiableModel

/// A minimal protocol for models to be stored persistently.
public protocol IdentifiableModel {
  var stringID: String { get }
}
