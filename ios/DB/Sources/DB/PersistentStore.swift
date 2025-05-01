//
//  PersistentStore.swift
//  DB
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

import Foundation
import SwiftData

// MARK: - PersistentStore

/// Defines an interface for saving, retrieving, and deleting persistent data.
public protocol PersistentStore {
  /// Saves a single item.
  func save<T: PersistentModel>(_ item: T) throws

  /// Saves multiple items.
  func save<T: PersistentModel>(_ items: [T]) throws

  /// Fetches all items of a given type.
  func fetch<T: PersistentModel>() throws -> [T]

  /// Fetches a single item by ID.
  func fetch<T: PersistentModel>(id: String) throws -> T?

  /// Deletes a single item.
  func delete<T: PersistentModel>(_ item: T) throws

  /// Deletes multiple items.
  func delete<T: PersistentModel>(_ items: [T]) throws
}

// MARK: - PersistentModel

/// A minimal protocol for models to be stored persistently.
public protocol PersistentModel {
  var id: String { get }
}

