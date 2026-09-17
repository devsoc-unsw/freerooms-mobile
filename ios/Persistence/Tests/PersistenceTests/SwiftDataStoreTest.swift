//
//  DataStore.swift
//  Persistence
//
//  Created by Dicko Evaldo on 4/7/2025.
//
import SwiftData
import Testing
@testable import Persistence
@testable import PersistenceTestUtils

@Suite(.serialized)
class DataStoreTest {

  // MARK: Lifecycle

  deinit {
    try? sut.deleteAll()
  }

  // MARK: Internal

  var sut = try! makeSUT()

  static func makeSUT() throws -> SwiftDataStore<GenericModel> {
    let schema = Schema([GenericModel.self])
    let modelConfiguration = ModelConfiguration(schema: schema)
    let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    let modelContext = ModelContext(modelContainer)
    return try SwiftDataStore(modelContext: modelContext)
  }

  func compareTwoArrays(arr1: [GenericModel], arr2: [GenericModel]) -> Bool {
    let sortedArr1 = arr1.sorted { $0.stringID < $1.stringID }
    let sortedArr2 = arr2.sorted { $0.stringID < $1.stringID }

    return sortedArr1 == sortedArr2
  }

  @Test("Testing fetch works after save")
  func fetchAfterSave() throws {
    // Given
    let item = GenericModel(stringID: "1")

    // When
    try sut.save(item)
    let result = try sut.fetch(id: "1")

    // Then
    #expect(result.unsafelyUnwrapped == item)
  }

  @Test("Testing fetchAll after save", .serialized, arguments: 1 ... 3)
  func fetchAllAfterSave(count: Int) throws {
    // Given
    var items = [GenericModel]()
    for i in 1 ... count {
      items.append(GenericModel(stringID: String(i)))
    }

    // When
    try sut.save(items)
    let result = try sut.fetchAll()

    // Then
    #expect(compareTwoArrays(arr1: result, arr2: items))
  }

  @Test
  func deleteAfterSave() throws {
    // Given
    let item = GenericModel(stringID: "1")
    try sut.save(item)

    // When
    try sut.delete(item)

    // Then
    let deletedItem = try sut.fetch(id: "1")
    #expect(deletedItem == nil)
  }

  @Test("Testing delete multiple items after save", .serialized, arguments: 1 ... 3)
  func deleteAllAfterSave(count: Int) throws {
    // Given
    var items = [GenericModel]()
    for i in 1 ... count {
      items.append(GenericModel(stringID: String(i)))
    }

    // When
    try sut.delete(items)

    // Then
    let deletedItems = try sut.fetchAll()
    #expect(deletedItems.isEmpty)
  }

  @Test
  func saveOnce() throws {
    // Given
    let item = GenericModel(stringID: "1")

    // When
    try sut.save(item)

    // Then
    let savedItem = try sut.fetch(id: "1")
    #expect(savedItem == item)
  }

  @Test("Testing saving multiple items", .serialized, arguments: 1 ... 3)
  func saveMultipleTimes(count: Int) throws {
    // Given
    var items = [GenericModel]()
    for i in 1 ... count {
      items.append(GenericModel(stringID: String(i)))
    }

    // When
    try sut.save(items)

    // Then
    let savedItems = try sut.fetchAll()
    #expect(compareTwoArrays(arr1: savedItems, arr2: items))
  }
}
