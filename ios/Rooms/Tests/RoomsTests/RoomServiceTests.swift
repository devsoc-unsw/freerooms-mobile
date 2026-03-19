//
//  RoomServiceTests.swift
//  RoomsTests
//
//  Created by Muqueet Mohsen Chowdhury on 5/8/2025.
//

import Testing
@testable import RoomModels
@testable import RoomServices
@testable import RoomTestUtils

// MARK: - RoomServiceTests

struct RoomServiceTests {

  @Test("RoomService returns rooms for valid building ID")
  func returnsRoomsForValidBuildingId() async {
    // Given
    let expectedRooms = createRooms(1)
    let stubLoader = StubRoomLoader()
    stubLoader.fetchBuildingIdReturnValue = .success(expectedRooms)

    let stubRemoteBookingLoader = StubRemoteRoomBookingLoader()
    let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: stubRemoteBookingLoader)
    let sut = LiveRoomService(
      roomLoader: stubLoader,
      roomBookingLoader: roomBookingLoader,
      roomRatingLoader: StubRoomRatingLoader())

    // When
    let result = await sut.getRooms(buildingId: "K-J17")

    // Then
    switch result {
    case .success(let rooms):
      #expect(rooms == expectedRooms)
    case .failure:
      Issue.record("Expected success but got failure")
    }
  }

  @Test("RoomService returns empty array when building has no rooms")
  func returnsEmptyArrayWhenBuildingHasNoRooms() async {
    // Given
    let stubLoader = StubRoomLoader()
    stubLoader.fetchBuildingIdReturnValue = .success([])
    let stubRemoteBookingLoader = StubRemoteRoomBookingLoader()
    let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: stubRemoteBookingLoader)
    let sut = LiveRoomService(
      roomLoader: stubLoader,
      roomBookingLoader: roomBookingLoader,
      roomRatingLoader: StubRoomRatingLoader())

    // When
    let result = await sut.getRooms(buildingId: "K-F21")

    // Then
    switch result {
    case .success(let rooms):
      #expect(rooms.isEmpty)
    case .failure:
      Issue.record("Expected success but got failure")
    }
  }

  @Test("RoomService returns connectivity error when loader fails")
  func returnsConnectivityErrorWhenLoaderFails() async {
    // Given
    let stubLoader = StubRoomLoader()
    stubLoader.fetchBuildingIdReturnValue = .failure(.connectivity)
    let stubRemoteBookingLoader = StubRemoteRoomBookingLoader()
    let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: stubRemoteBookingLoader)
    let sut = LiveRoomService(
      roomLoader: stubLoader,
      roomBookingLoader: roomBookingLoader,
      roomRatingLoader: StubRoomRatingLoader())

    // When
    let result = await sut.getRooms(buildingId: "K-J17")

    // Then
    switch result {
    case .success:
      Issue.record("Expected failure but got success")
    case .failure(let error):
      #expect(error == .connectivity)
    }
  }

  @Test("RoomService returns multiple rooms correctly")
  func returnsMultipleRoomsCorrectly() async {
    // Given
    let expectedRooms = createRooms(3)
    let stubLoader = StubRoomLoader()
    stubLoader.fetchBuildingIdReturnValue = .success(expectedRooms)
    let stubRemoteBookingLoader = StubRemoteRoomBookingLoader()
    let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: stubRemoteBookingLoader)
    let sut = LiveRoomService(
      roomLoader: stubLoader,
      roomBookingLoader: roomBookingLoader,
      roomRatingLoader: StubRoomRatingLoader())

    // When
    let result = await sut.getRooms(buildingId: "K-J17")

    // Then
    switch result {
    case .success(let rooms):
      #expect(rooms.count == 3)
      #expect(rooms == expectedRooms)

    case .failure:
      Issue.record("Expected success but got failure")
    }
  }

  @Test("RoomService returns error for empty building ID")
  func returnsErrorForEmptyBuildingId() async {
    // Given
    let stubLoader = StubRoomLoader()
    let stubRemoteBookingLoader = StubRemoteRoomBookingLoader()
    let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: stubRemoteBookingLoader)
    let sut = LiveRoomService(
      roomLoader: stubLoader,
      roomBookingLoader: roomBookingLoader,
      roomRatingLoader: StubRoomRatingLoader())

    // When
    let result = await sut.getRooms(buildingId: "")

    // Then
    switch result {
    case .success:
      Issue.record("Expected failure but got success")
    case .failure(let error):
      #expect(error == .invalidBuildingId)
    }
  }
}
