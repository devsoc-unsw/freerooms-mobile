//
//  LiveSwiftDataBuildingLoaderTests.swift
//  Buildings
//
//  Created by Muqueet Mohsen Chowdhury on 29/6/2025.
//

import BuildingModels
import BuildingServices
import Foundation
import Persistence
import Testing
import TestingSupport

struct LiveSwiftDataBuildingLoaderTests {

  // MARK: Internal

  @Test("LiveSwiftDataBuildingLoader fetches three buildings from its store")
  func fetchBuildingsFromLiveSwiftDataBuildingLoader() async {
    // Given
    let swiftDataBuildings = createSwiftDataBuildings(3)
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(loads: swiftDataBuildings)
    let sut = LiveSwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

    // Then
    let expectedBuildings = createBuildings(3)
    expect(result, toFetch: expectedBuildings)
  }

  @Test("LiveSwiftDataBuildingLoader throws noDataAvailable error when its store is empty")
  func fetchBuildingsThrowsNoDataErrorOnEmptyStore() async {
    // Given
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(loads: [])
    let sut = LiveSwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

    // Then
    expect(result, toThrow: BuildingLoaderError.noDataAvailable)
  }

  @Test("LiveSwiftDataBuildingLoader throws persistenceError on store failure")
  func fetchBuildingsThrowsPersistenceErrorOnStoreFailure() async {
    // Given
    let mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(throws: mockError)
    let sut = LiveSwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

    // Then
    expect(result, toThrow: BuildingLoaderError.persistenceError)
  }

  @Test("LiveSwiftDataBuildingLoader returns empty array when no buildings available")
  func LiveSwiftDataBuildingLoaderReturnsEmptyArrayWhenNoBuildings() async {
    // Given
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(loads: [])
    let sut = LiveSwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

    // Then
    expect(result, toThrow: BuildingLoaderError.noDataAvailable)
  }

  @Test("LiveSwiftDataBuildingLoader returns single building successfully")
  func LiveSwiftDataBuildingLoaderReturnsSingleBuilding() async {
    // Given
    let swiftDataBuildings = createSwiftDataBuildings(1)
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataBuilding>(loads: swiftDataBuildings)
    let sut = LiveSwiftDataBuildingLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

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

  private func expect(_ result: Result<[Building], BuildingLoaderError>, toFetch expectedBuildings: [Building]) {
    switch result {
    case .success(let buildings):
      #expect(buildings == expectedBuildings)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

  private func expect(_ result: Result<[Building], BuildingLoaderError>, toThrow expectedError: BuildingLoaderError) {
    switch result {
    case .failure(let error):
      #expect(error == expectedError)
    case .success(let buildings):
      Issue.record("Expected error \(expectedError) but got success with \(buildings)")
    }
  }
}
