//
//  LiveRemoteRoomLoaderTests.swift
//  RoomsTests
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

import Foundation
import Networking
import Testing
@testable import RoomModels

// MARK: - LiveRemoteRoomLoaderTests

struct LiveRemoteRoomLoaderTests {

  @Test("LiveRemoteRoomLoader fetches remote rooms successfully")
  func fetchesRemoteRoomsSuccessfully() async {
    // Given
    let expectedRemoteRooms = [
      RemoteRoom(name: "Ainsworth G03", id: "K-J17-G03", abbreviation: "Ains G03", capacity: 350, usage: "LEC", school: "UNSW"),
      RemoteRoom(name: "Ainsworth G04", id: "K-J17-G04", abbreviation: "Ains G04", capacity: 200, usage: "TUT", school: "UNSW"),
    ]
    let mockClient = MockHTTPClient()
    mockClient.stubSuccess(expectedRemoteRooms, for: "K-J17")
    let baseURL = URL(string: "https://api.example.com")!
    let sut = LiveRemoteRoomLoader(client: mockClient, baseURL: baseURL)

    // When
    let result = await sut.fetch(buildingId: "K-J17")

    // Then
    switch result {
    case .success(let remoteRooms):
      #expect(remoteRooms == expectedRemoteRooms)
    case .failure:
      Issue.record("Expected success but got failure")
    }
  }

  @Test("LiveRemoteRoomLoader returns connectivity error when client fails")
  func returnsConnectivityErrorWhenClientFails() async {
    // Given
    let mockClient = MockHTTPClient()
    mockClient.stubFailure()
    let baseURL = URL(string: "https://api.example.com")!
    let sut = LiveRemoteRoomLoader(client: mockClient, baseURL: baseURL)

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
}
