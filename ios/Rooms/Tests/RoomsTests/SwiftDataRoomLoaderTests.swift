//
//  SwiftDataRoomLoaderTests.swift
//  Rooms
//
//  Created by Chris Wong on 3/9/2025.
//

import Testing
import RoomServices
@testable import PersistenceTestUtils
@testable import RoomTestUtils
import RoomModels
import Foundation

struct SwiftDataRoomLoaderTests {
  @Test("LiveSwiftDataBuildingLoader fetches three buildings from its store")
  func fetchBuildingsFromLiveSwiftDataBuildingLoader() async {
    // Given
    let swiftDataRooms = createSwiftDataRooms(3)
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataRoom>(loads: swiftDataRooms)
    let sut = LiveSwiftDataRoomLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

    // Then
    let expectedRooms = createRooms(3)
    expect(result, toFetch: expectedRooms)
  }

  @Test("LiveSwiftDataBuildingLoader throws noDataAvailable error when its store is empty")
  func fetchBuildingsThrowsNoDataErrorOnEmptyStore() async {
    // Given
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataRoom>(loads: [])
    let sut = LiveSwiftDataRoomLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

    // Then
    expect(result, toThrow: RoomLoaderError.noDataAvailable)
  }

  @Test("LiveSwiftDataBuildingLoader throws persistenceError on store failure")
  func fetchBuildingsThrowsPersistenceErrorOnStoreFailure() async {
    // Given
    let mockError = NSError(domain: "TestError", code: 1, userInfo: nil)
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataRoom>(throws: mockError)
    let sut = LiveSwiftDataRoomLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

    // Then
    expect(result, toThrow: RoomLoaderError.persistenceError)
  }

  @Test("LiveSwiftDataBuildingLoader returns empty array when no buildings available")
  func LiveSwiftDataBuildingLoaderReturnsEmptyArrayWhenNoBuildings() async {
    // Given
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataRoom>(loads: [])
    let sut = LiveSwiftDataRoomLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

    // Then
    expect(result, toThrow: RoomLoaderError.noDataAvailable)
  }

  @Test("LiveSwiftDataBuildingLoader returns single building successfully")
  func LiveSwiftDataBuildingLoaderReturnsSingleBuilding() async {
    // Given
    let swiftDataRooms = createSwiftDataRooms(1)
    let mockSwiftDataStore = MockSwiftDataStore<SwiftDataRoom>(loads: swiftDataRooms)
    let sut = LiveSwiftDataRoomLoader(swiftDataStore: mockSwiftDataStore)

    // When
    let result = sut.fetch()

    // Then
    let expectedRooms = createRooms(1)
    expect(result, toFetch: expectedRooms)
  }

  // MARK: Private

  private func expect(_ result: Result<[Room], RoomLoaderError>, toFetch expectedBuildings: [Room]) {
    switch result {
    case .success(let buildings):
      #expect(buildings == expectedBuildings)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

  private func expect(_ result: Result<[Room], RoomLoaderError>, toThrow expectedError: RoomLoaderError) {
    switch result {
    case .failure(let error):
      #expect(error == expectedError)
    case .success(let buildings):
      Issue.record("Expected error \(expectedError) but got success with \(buildings)")
    }
  }

}
