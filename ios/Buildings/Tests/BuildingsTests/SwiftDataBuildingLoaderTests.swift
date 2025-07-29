//
//  SwiftDataBuildingLoaderTests.swift
//  Buildings
//
//  Created by Muqueet Mohsen Chowdhury on 29/6/2025.
//

import Buildings
import Foundation
import Persistence
import Testing
import TestingSupport

struct SwiftDataBuildingLoaderTests {

  // MARK: Internal

  @Test("SwiftDataBuildingLoader fetches three buildings from its store")
  func fetchBuildingsFromSwiftDataBuildingLoader() async {
    // Given
    let swiftDataBuildings = createSwiftDataBuildings(3)
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(loads: swiftDataBuildings)
    let sut = SwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = await sut.fetch()

    // Then
    let expectedBuildings = createBuildings(3)
    expect(result, toFetch: expectedBuildings)
  }

  @Test("SwiftDataBuildingLoader throws noDataAvailable error when its store is empty")
  func fetchBuildingsThrowsNoDataErrorOnEmptyStore() async {
    // Given
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(loads: [])
    let sut = SwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = await sut.fetch()

    // Then
    expect(result, toThrow: BuildingLoaderError.noDataAvailable)
  }

  @Test("SwiftDataBuildingLoader throws persistenceError on store failure")
  func fetchBuildingsThrowsPersistenceErrorOnStoreFailure() async {
    // Given
    let mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(throws: mockError)
    let sut = SwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = await sut.fetch()

    // Then
    expect(result, toThrow: BuildingLoaderError.persistenceError)
  }

  @Test("SwiftDataBuildingLoader returns empty array when no buildings available")
  func swiftDataBuildingLoaderReturnsEmptyArrayWhenNoBuildings() async {
    // Given
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(loads: [])
    let sut = SwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = await sut.fetch()

    // Then
    expect(result, toThrow: BuildingLoaderError.noDataAvailable)
  }

  @Test("SwiftDataBuildingLoader returns single building successfully")
  func swiftDataBuildingLoaderReturnsSingleBuilding() async {
    // Given
    let swiftDataBuildings = createSwiftDataBuildings(1)
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(loads: swiftDataBuildings)
    let sut = SwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = await sut.fetch()

    // Then
    let expectedBuildings = createBuildings(1)
    expect(result, toFetch: expectedBuildings)
  }

  // MARK: Private

  private func createSwiftDataBuildings(_ count: Int) -> [SwiftDataBuilding] {
    var buildings: [SwiftDataBuilding] = []
    for i in 0..<count {
      let building = SwiftDataBuilding(
        name: "Building \(i)",
        id: "K-E\(i)",
        latitude: Double(i),
        longitude: Double(i),
        aliases: ["Alias\(i)"],
        numberOfAvailableRooms: i)
      buildings.append(building)
    }
    return buildings
  }

  private func createBuildings(_ count: Int) -> [Building] {
    var buildings: [Building] = []
    for i in 0..<count {
      let building = Building(
        name: "Building \(i)",
        id: "K-E\(i)",
        latitude: Double(i),
        longitude: Double(i),
        aliases: ["Alias\(i)"],
        numberOfAvailableRooms: i)
      buildings.append(building)
    }
    return buildings
  }

  private func expect(_ result: Result<[Building], Error>, toFetch expectedBuildings: [Building]) {
    switch result {
    case .success(let buildings):
      #expect(buildings == expectedBuildings)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

  private func expect(_ result: Result<[Building], Error>, toThrow expectedError: BuildingLoaderError) {
    switch result {
    case .failure(let error):
      #expect(checkErrorEquals(error, equals: expectedError, as: BuildingLoaderError.self) == true)
    case .success(let buildings):
      Issue.record("Expected error \(expectedError) but got success with \(buildings)")
    }
  }
}
