//
//  LiveRoomLoaderTests.swift
//  RoomsTests
//
//  Created by Muqueet Mohsen Chowdhury on 5/8/2025.
//

import Testing
@testable import Rooms

// MARK: - LiveRoomLoaderTests

struct LiveRoomLoaderTests {

  @Test("LiveRoomLoader maps remote rooms to rooms successfully")
  func mapsRemoteRoomsToRoomsSuccessfully() async {
    // Given
    let remoteRooms = [
      RemoteRoom(name: "Ainsworth G03", id: "K-J17-G03", abbreviation: "Ains G03", capacity: 350, usage: "LEC", school: "UNSW"),
      RemoteRoom(name: "Ainsworth G04", id: "K-J17-G04", abbreviation: "Ains G04", capacity: 200, usage: "TUT", school: "UNSW"),
    ]
    let expectedRooms = [
      Room(name: "Ainsworth G03", id: "K-J17-G03", abbreviation: "Ains G03", capacity: 350, usage: "LEC", school: "UNSW"),
      Room(name: "Ainsworth G04", id: "K-J17-G04", abbreviation: "Ains G04", capacity: 200, usage: "TUT", school: "UNSW"),
    ]
    let mockRemoteLoader = MockRemoteRoomLoader()
    mockRemoteLoader.stubRemoteRooms(remoteRooms, for: "K-J17")
    let sut = LiveRoomLoader(remoteRoomLoader: mockRemoteLoader)

    // When
    let result = await sut.fetch(buildingId: "K-J17")

    // Then
    switch result {
    case .success(let rooms):
      #expect(rooms == expectedRooms)
    case .failure:
      Issue.record("Expected success but got failure")
    }
  }

  @Test("LiveRoomLoader returns connectivity error when remote loader fails")
  func returnsConnectivityErrorWhenRemoteLoaderFails() async {
    // Given
    let mockRemoteLoader = MockRemoteRoomLoader()
    mockRemoteLoader.stubError(.connectivity)
    let sut = LiveRoomLoader(remoteRoomLoader: mockRemoteLoader)

    // When
    let result = await sut.fetch(buildingId: "K-J17")

    // Then
    switch result {
    case .success:
      Issue.record("Expected failure but got success")
    case .failure(let error):
      #expect(error == .connectivity)
    }
  }

  @Test("LiveRoomLoader returns empty array when remote loader returns empty array")
  func returnsEmptyArrayWhenRemoteLoaderReturnsEmptyArray() async {
    // Given
    let mockRemoteLoader = MockRemoteRoomLoader()
    mockRemoteLoader.stubRemoteRooms([], for: "K-J17")
    let sut = LiveRoomLoader(remoteRoomLoader: mockRemoteLoader)

    // When
    let result = await sut.fetch(buildingId: "K-J17")

    // Then
    switch result {
    case .success(let rooms):
      #expect(rooms.isEmpty)
    case .failure:
      Issue.record("Expected success but got failure")
    }
  }
}

// MARK: - MockRemoteRoomLoader

private class MockRemoteRoomLoader: RemoteRoomLoader {

  // MARK: Internal

  func stubRemoteRooms(_ remoteRooms: [RemoteRoom], for buildingId: String) {
    stubbedRemoteRooms[buildingId] = remoteRooms
  }

  func stubError(_ error: RemoteRoomLoaderError) {
    stubbedError = error
  }

  func fetch(buildingId: String) async -> Result<[RemoteRoom], RemoteRoomLoaderError> {
    if let error = stubbedError {
      return .failure(error)
    }

    if let remoteRooms = stubbedRemoteRooms[buildingId] {
      return .success(remoteRooms)
    }
    return .failure(.connectivity)
  }

  // MARK: Private

  private var stubbedRemoteRooms: [String: [RemoteRoom]] = [:]
  private var stubbedError: RemoteRoomLoaderError?

}
