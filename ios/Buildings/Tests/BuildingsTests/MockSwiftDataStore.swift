//
//  MockSwiftDataStore.swift
//  Buildings
//
//  Created by Muqueet Mohsen Chowdhury on 29/6/2025.
//

import Foundation
import Persistence
import SwiftData

public class MockSwiftDataStore<Model: PersistentModel & IdentifiableModel>: PersistentStore {

  // MARK: Lifecycle

  public init(loads items: [Model] = [], throws error: Error? = nil) {
    self.items = items
    self.error = error
  }

  // MARK: Public

  public func save(_: Model) throws {
    if let error {
      throw error
    }
    // Mock implementation - no actual saving needed
  }

  public func save(_: [Model]) throws {
    if let error {
      throw error
    }
    // Mock implementation - no actual saving needed
  }

  public func fetchAll() throws -> [Model] {
    if let error {
      throw error
    }
    return items
  }

  public func fetch(id: String) throws -> Model? {
    if let error {
      throw error
    }
    return items.first { $0.stringID == id }
  }

  public func delete(_: Model) throws {
    if let error {
      throw error
    }
    // Mock implementation - no actual deletion needed
  }

  public func delete(_: [Model]) throws {
    if let error {
      throw error
    }
    // Mock implementation - no actual deletion needed
  }

  // MARK: Private

  private let items: [Model]
  private let error: Error?
}
