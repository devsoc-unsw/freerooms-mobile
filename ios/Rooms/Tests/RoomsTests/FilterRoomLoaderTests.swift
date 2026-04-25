//
//  FilterRoomLoaderTests.swift
//  Rooms
//
//  Created by Yanlin Li on 26/4/2026.
//

import Foundation
import Networking
import RoomModels
import RoomServices
import Testing
import RoomTestUtils

@Suite
struct FilterRoomLoaderTests {

  @Test
  func fetchFilteredRooms_success_returnsRoomIdsFromResponseMap() async throws {
    let client = HTTPClientSpy()

    client.result = .success(makeHTTPResponse(
      route: "/api/rooms/search",
      json: """
      {
        "K-G27-108": {
          "status": "free",
          "endtime": "",
          "name": "AGSM 108 Ex Phys Motor Control"
        },
        "K-G27-109": {
          "status": "free",
          "endtime": "",
          "name": "AGSM 109 Exercise Physiology"
        }
      }
      """
    ))

    let sut = LiveFilterRoomLoader(
      client: client,
      baseURL: URL(string: "https://freerooms.devsoc.app")!
    )

    let result = await sut.fetchFilteredRooms(
      dateTime: "2026-04-17T06:07:40.097Z",
      startTime: nil,
      endTime: nil,
      buildingId: nil,
      capacity: nil,
      duration: 120,
      usage: nil,
      location: nil,
      SortedBySpecificSchoolId: false
    )

    switch result {
    case .success(let roomIds):
      print(roomIds)
      #expect(Set(roomIds) == Set(["K-G27-108", "K-G27-109"]))

    case .failure(let error):
      Issue.record("Expected success, got failure: \(error)")
    }
  }

  @Test
  func fetchFilteredRooms_sendsFilterValuesAsQueryParameters() async throws {
    let client = HTTPClientSpy()

    client.result = .success(makeHTTPResponse(
      route: "/api/rooms/search",
      json: """
      {
        "K-G27-108": {
          "status": "free",
          "endtime": "",
          "name": "AGSM 108 Ex Phys Motor Control"
        }
      }
      """
    ))

    let sut = LiveFilterRoomLoader(
      client: client,
      baseURL: URL(string: "https://freerooms.devsoc.app")!
    )

    _ = await sut.fetchFilteredRooms(
      dateTime: "2026-04-17T06:07:40.097Z",
      startTime: "09:00",
      endTime: "11:00",
      buildingId: "K-G27",
      capacity: 20,
      duration: 120,
      usage: "study",
      location: "Kensington",
      SortedBySpecificSchoolId: true
    )

    let url = try #require(client.requestedURLs.first)
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: true))
    let queryItems = Dictionary(
      uniqueKeysWithValues: (components.queryItems ?? []).map {
        ($0.name, $0.value ?? "")
      }
    )

    #expect(components.path == "/api/rooms/search")

    // These should match the backend spec exactly.
    #expect(queryItems["datetime"] == "2026-04-17T06:07:40.097Z")
    #expect(queryItems["startTime"] == "09:00")
    #expect(queryItems["endTime"] == "11:00")
    #expect(queryItems["buildingId"] == "K-G27")
    #expect(queryItems["capacity"] == "20")
    #expect(queryItems["duration"] == "120")
    #expect(queryItems["usage"] == "study")
    #expect(queryItems["location"] == "Kensington")
    #expect(queryItems["id"] == "true")
  }

  @Test
  func fetchFilteredRooms_withNilFilters_sendsEmptyQueryValues() async throws {
    let client = HTTPClientSpy()

    client.result = .success(makeHTTPResponse(
      route: "/api/rooms/search",
      json: """
      {}
      """
    ))

    let sut = LiveFilterRoomLoader(
      client: client,
      baseURL: URL(string: "https://freerooms.devsoc.app")!
    )

    _ = await sut.fetchFilteredRooms(
      dateTime: nil,
      startTime: nil,
      endTime: nil,
      buildingId: nil,
      capacity: nil,
      duration: nil,
      usage: nil,
      location: nil,
      SortedBySpecificSchoolId: false
    )

    let url = try #require(client.requestedURLs.first)
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: true))
    let queryItems = Dictionary(
      uniqueKeysWithValues: (components.queryItems ?? []).map {
        ($0.name, $0.value ?? "")
      }
    )

    #expect(queryItems["datetime"] == "")
    #expect(queryItems["startTime"] == "")
    #expect(queryItems["endTime"] == "")
    #expect(queryItems["buildingId"] == "")
    #expect(queryItems["capacity"] == "")
    #expect(queryItems["duration"] == "")
    #expect(queryItems["usage"] == "")
    #expect(queryItems["location"] == "")
    #expect(queryItems["id"] == "false")
  }

  @Test
  func fetchFilteredRooms_whenClientFails_returnsConnectivityError() async throws {
    let client = HTTPClientSpy()
    client.result = .failure(AnyError())

    let sut = LiveFilterRoomLoader(
      client: client,
      baseURL: URL(string: "https://freerooms.devsoc.app")!
    )

    let result = await sut.fetchFilteredRooms(
      dateTime: nil,
      startTime: nil,
      endTime: nil,
      buildingId: nil,
      capacity: nil,
      duration: nil,
      usage: nil,
      location: nil,
      SortedBySpecificSchoolId: false
    )

    #expect(result == .failure(.connectivity))
  }

  @Test
  func fetchFilteredRooms_whenResponseIsInvalidJSON_returnsConnectivityError() async throws {
    let client = HTTPClientSpy()

    client.result = .success(makeHTTPResponse(
      route: "/api/rooms/search",
      json: """
      not valid json
      """
    ))

    let sut = LiveFilterRoomLoader(
      client: client,
      baseURL: URL(string: "https://freerooms.devsoc.app")!
    )

    let result = await sut.fetchFilteredRooms(
      dateTime: nil,
      startTime: nil,
      endTime: nil,
      buildingId: nil,
      capacity: nil,
      duration: nil,
      usage: nil,
      location: nil,
      SortedBySpecificSchoolId: false
    )

    #expect(result == .failure(.connectivity))
  }
}
