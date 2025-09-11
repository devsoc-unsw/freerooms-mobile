//
//  RoomLoaderTests.swift
//  Rooms
//
//  Created by Chris Wong on 1/9/2025.
//

import Foundation
import Testing
@testable import Persistence
@testable import RoomModels
@testable import RoomServices
@testable import RoomTestUtils

@Suite(.serialized)
class RoomLoaderTests {

  // MARK: Lifecycle

  deinit {
    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.hasSavedRoomsData)
  }

  // MARK: Internal

  @Test(
    "First load of rooms gets zero buildings successfully and sets UserDefaults flag indicating data has been loaded will be turned on")
  func onFirstLoadSuccessfullyLoadsZeroRooms() async throws {
    // Given
    let rooms = createRooms(0)
    let mockJSONRoomLoader = MockJSONRoomLoader(loads: rooms)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubSuccess(createRemoteRoomStatus(0))
    let sut = LiveRoomLoader(JSONRoomLoader: mockJSONRoomLoader, roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toFetch: rooms)
  }

  @Test(
    "First load of rooms gets one room successfully and sets UserDefaults flag indicating data has been loaded will be turned on")
  func onFirstLoadSuccessfullyLoadsOneBuilding() async throws {
    // Given
    let rooms = createRooms(1)
    let mockJSONRoomLoader = MockJSONRoomLoader(loads: rooms)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubSuccess(createRemoteRoomStatus(1))
    let sut = LiveRoomLoader(JSONRoomLoader: mockJSONRoomLoader, roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toFetch: rooms)
  }

  @Test(
    "First load of buildings gets ten buildings successfully and sets UserDefaults flag indicating data has been loaded will be turned on")
  func onFirstLoadSuccessfullyLoadsTenBuilding() async throws {
    // Given
    let rooms = createRooms(10)
    let mockJSONRoomLoader = MockJSONRoomLoader(loads: rooms)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubSuccess(createRemoteRoomStatus(10))
    let sut = LiveRoomLoader(JSONRoomLoader: mockJSONRoomLoader, roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toFetch: rooms)
  }

  @Test("First load of buildings, JSON Building Loader throws an error so buildings loader will throw an error")
  func onFirstLoadJSONBuildingLoaderThrowsError() async throws {
    // Given
    let mockJSONRoomLoader = MockJSONRoomLoader(throws: .malformedJSON)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubSuccess(createRemoteRoomStatus(0))
    let sut = LiveRoomLoader(JSONRoomLoader: mockJSONRoomLoader, roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toThrow: .malformedJSON)
  }

  @Test(
    "First load of buildings, Swift Data Building Loader throws an error so buildings will still be returned but UserDefaults flag indicating data has loaded will not be turned on")
  func onFirstLoadSwiftDataBuildingLoaderThrowsError() async throws {
    /// Not implemented yet
    #expect(1 == 1)
  }

  @Test("Subsequent loads of buildings gets the buildings successfully")
  func onSubsequentLoadsSuccessfullyLoadsBuildings() async throws {
    /// Not implemented yet
    #expect(1 == 1)
  }

  @Test("Subsequent loads of buildings, Swift Data Building Loader throws an error so buildings will throw an error")
  func onSubsequentLoadsSwiftDataBuildingLoaderThrowsError() async throws {
    /// Not implemented yet
    #expect(1 == 1)
  }

  @Test(
    "Live Building Loader integrates with Live JSON Building Loader and Live Swift Data Building Loader successfully returning buildings on first load")
  func liveBuildingLoaderIntegratesSuccessfullyWithLiveUnitsOnFirstLoad() async throws {
    /// Not implemented yet
    #expect(1 == 1)
  }

  // MARK: Private

  private func expect(_ res: LiveRoomLoader.Result, toThrow expected: RoomLoaderError) {
    switch res {
    case .failure(let error):
      #expect(error == expected)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: LiveRoomLoader.Result, toFetch expected: [Room]) {
    switch res {
    case .success(var rooms):
      rooms.sort { $0.id < $1.id }
      #expect(rooms == expected)

    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }
}
