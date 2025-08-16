//
//  RoomsTests.swift
//  RoomsTests
//
//  Created by Muqueet Mohsen Chowdhury on 5/8/2025.
//

import Testing

// MARK: - RoomServiceTests

struct RoomServiceTests {

  @Test("RoomService returns rooms for valid building ID")
  func returnsRoomsForValidBuildingId() async {
    // Given
    let expectedRooms = [
      Room(name: "Ainsworth G03", id: "K-J17-G03", abbreviation: "Ains G03", capacity: 350, usage: "LEC", school: "UNSW"),
    ]
    let mockLoader = MockRoomLoader()
    mockLoader.stubRooms(expectedRooms, for: "K-J17")
    let sut = LiveRoomService(roomLoader: mockLoader)

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
    let mockLoader = MockRoomLoader()
    mockLoader.stubRooms([], for: "K-F21")
    let sut = LiveRoomService(roomLoader: mockLoader)

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
    let mockLoader = MockRoomLoader()
    mockLoader.stubError(.connectivity)
    let sut = LiveRoomService(roomLoader: mockLoader)

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
    let expectedRooms = [
      Room(name: "Ainsworth G03", id: "K-J17-G03", abbreviation: "Ains G03", capacity: 350, usage: "LEC", school: "UNSW"),
      Room(name: "Ainsworth G04", id: "K-J17-G04", abbreviation: "Ains G04", capacity: 200, usage: "TUT", school: "UNSW"),
      Room(name: "Ainsworth 201", id: "K-J17-201", abbreviation: "Ains 201", capacity: 50, usage: "LAB", school: "CSE"),
    ]
    let mockLoader = MockRoomLoader()
    mockLoader.stubRooms(expectedRooms, for: "K-J17")
    let sut = LiveRoomService(roomLoader: mockLoader)

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

  @Test("PreviewRoomService returns mock rooms")
  func previewServiceReturnsMockRooms() async {
    // Given
    let sut = PreviewRoomService()

    // When
    let result = await sut.getRooms(buildingId: "K-J17")

    // Then
    switch result {
    case .success(let rooms):
      #expect(rooms.count == 3)
      #expect(rooms.first?.id == "K-J17-G03")

    case .failure:
      Issue.record("Expected success but got failure")
    }
  }

  @Test("RoomService returns error for empty building ID")
  func returnsErrorForEmptyBuildingId() async {
    // Given
    let mockLoader = MockRoomLoader()
    let sut = LiveRoomService(roomLoader: mockLoader)

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
