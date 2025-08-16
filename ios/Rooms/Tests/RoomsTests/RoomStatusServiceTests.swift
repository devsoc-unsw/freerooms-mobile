//
//  RoomStatusServiceTests.swift
//  RoomsTests
//
//  Created by Muqueet Mohsen Chowdhury on 16/8/2025.
//

import Foundation
import Testing
@testable import RoomServices

struct RoomStatusServiceTests {

  @Test("getFreeRoomCount returns number of free rooms for building")
  func returnsFreeCount() async {
    let mockClient = MockHTTPClient()
    let baseURL = URL(string: "https://api.example.com/api")!

    // Stub example: K-J17 has G01=free, G02=busy, G03=free → count=2
    let payload: [String: [String: RemoteRoomStatus]] = [
      "K-J17": [
        "G01": .init(status: "free", endtime: ""),
        "G02": .init(status: "busy", endtime: "2025-08-16T09:00:00.000Z"),
        "G03": .init(status: "free", endtime: ""),
      ],
    ]
    mockClient.stubSuccess(payload, for: "rooms/status")

    let sut = LiveRoomStatusService(client: mockClient, baseURL: baseURL)

    let result = await sut.getFreeRoomCount(buildingId: "K-J17")
    switch result {
    case .success(let count): #expect(count == 2)
    case .failure: Issue.record("Expected success")
    }
  }

  @Test("getFreeRoomCount returns 0 when building not present")
  func returnsZeroWhenBuildingMissing() async {
    let mockClient = MockHTTPClient()
    let baseURL = URL(string: "https://api.example.com/api")!

    let payload: [String: [String: RemoteRoomStatus]] = [
      "K-F21": [
        "G01": .init(status: "free", endtime: ""),
      ],
    ]
    mockClient.stubSuccess(payload, for: "rooms/status")

    let sut = LiveRoomStatusService(client: mockClient, baseURL: baseURL)

    let result = await sut.getFreeRoomCount(buildingId: "K-J17")
    switch result {
    case .success(let count): #expect(count == 0)
    case .failure: Issue.record("Expected success")
    }
  }

  @Test("getFreeRoomCount fails for empty buildingId")
  func failsForEmptyBuildingId() async {
    let mockClient = MockHTTPClient()
    let baseURL = URL(string: "https://api.example.com/api")!
    let sut = LiveRoomStatusService(client: mockClient, baseURL: baseURL)

    let result = await sut.getFreeRoomCount(buildingId: "")
    switch result {
    case .success: Issue.record("Expected failure")
    case .failure(let err): #expect(err == .invalidBuildingId)
    }
  }

  @Test("getFreeRoomCount fails on connectivity")
  func failsOnConnectivity() async {
    let mockClient = MockHTTPClient()
    mockClient.stubFailure()
    let baseURL = URL(string: "https://api.example.com/api")!
    let sut = LiveRoomStatusService(client: mockClient, baseURL: baseURL)

    let result = await sut.getFreeRoomCount(buildingId: "K-J17")
    switch result {
    case .success: Issue.record("Expected failure")
    case .failure(let err): #expect(err == .connectivity)
    }
  }
}
