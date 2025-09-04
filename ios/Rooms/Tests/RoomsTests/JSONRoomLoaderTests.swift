//
//  JSONRoomLoaderTests.swift
//  Rooms
//
//  Created by Chris Wong on 5/8/2025.
//

import RoomModels
import Testing
@testable import PersistenceTestUtils
@testable import RoomServices
@testable import RoomTestUtils

struct JSONRoomLoaderTests {

  // MARK: Internal

  @Test("Rooms Seed JSON is bundled")
  func RoomsSeedJSONIsBundled() {
    // Given
    let decodableRooms = createDecodableRooms(0)
    let mockJSONLoader = MockJSONLoader<[DecodableRoom]>(loads: decodableRooms)
    let liveJSONRoomLoader = LiveJSONRoomLoader(using: mockJSONLoader)

    // When
    let sut = liveJSONRoomLoader.roomsSeedJSONPath

    // Then
    if sut == nil {
      Issue.record("Rooms Seed JSON not found in bundle")
    }
  }

  @Test("JSON room loader successfully decodes JSON into type [Room] for zero DecodableRooms")
  func JSONRoomLoaderLoadsJSONForZeroDecodableRoom() {
    // Given
    let decodableRooms = createDecodableRooms(0)
    let rooms = createRooms(0)
    let mockJSONLoader = MockJSONLoader<[DecodableRoom]>(loads: decodableRooms)
    let sut = LiveJSONRoomLoader(using: mockJSONLoader)

    // When
    let res = sut.fetch()

    // Then
    expect(res, toFetch: rooms)
  }

  @Test("JSON room loader successfully decodes JSON into type [Room] for 1 DecodableRooms")
  func JSONRoomLoaderLoadsJSONForOneDecodableRoom() {
    // Given
    let decodableRooms = createDecodableRooms(1)
    let rooms = createRooms(1)
    let mockJSONLoader = MockJSONLoader<[DecodableRoom]>(loads: decodableRooms)
    let sut = LiveJSONRoomLoader(using: mockJSONLoader)

    // When
    let res = sut.fetch()

    // Then
    expect(res, toFetch: rooms)
  }

  @Test("JSON room loader successfully decodes JSON into type [Room] for 10 DecodableRooms")
  func JSONRoomLoaderLoadsJSONForTenDecodableRooms() {
    // Given
    let decodableRooms = createDecodableRooms(10)
    let rooms = createRooms(10)
    let mockJSONLoader = MockJSONLoader<[DecodableRoom]>(loads: decodableRooms)
    let sut = LiveJSONRoomLoader(using: mockJSONLoader)

    // When
    let res = sut.fetch()

    // Then
    expect(res, toFetch: rooms)
  }

  @Test("JSON room loader throws error when given malformed JSON")
  func JSONRoomLoaderThrowsMalformedJSONError() {
    // Given
    let mockJSONLoader = MockJSONLoader<[DecodableRoom]>(throws: .malformedJSON)
    let sut = LiveJSONRoomLoader(using: mockJSONLoader)

    // When
    let res = sut.fetch()

    // Then
    expect(res, toThrow: .malformedJSON)
  }

  @Test("JSON room loader throws error when given invalid file path")
  func JSONRoomLoaderThrowsErrorOnInvalidFilePath() {
    // Given
    let mockJSONLoader = MockJSONLoader<[DecodableRoom]>(throws: .fileNotFound)
    let sut = LiveJSONRoomLoader(using: mockJSONLoader)

    // When
    let res = sut.fetch()

    // Then
    expect(res, toThrow: .fileNotFound)
  }

  // MARK: Private

  private func expect(_ res: LiveJSONRoomLoader.Result, toThrow expected: RoomLoaderError) {
    switch res {
    case .failure(let error):
      #expect(error == expected)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: LiveJSONRoomLoader.Result, toFetch expected: [Room]) {
    switch res {
    case .success(let rooms):
      #expect(rooms == expected)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

  private func createDecodableRooms(_ count: Int) -> [DecodableRoom] {
    var decodableRooms: [DecodableRoom] = []
    for _ in 0..<count {
      decodableRooms.append(DecodableRoom(
        abbr: "SCI101",
        accessibility: ["Wheelchair accessible", "hearing loop available"],
        audiovisual: ["Projector", "speakers", "HDMI connection"],
        buildingId: "BLDG-2024-007",
        capacity: 45,
        floor: "Ground floor",
        id: "ROOM-12345-ABC",
        infoTechnology: [],
        lat: 40.7589,
        long: -73.9851,
        microphone: ["Wireless handheld", "Lapel mic", "Desktop mic"],
        name: "Science Lecture Hall A",
        school: "Metropolitan University",
        seating: "Theater-style fixed seating",
        usage: "Lectures, presentations, seminars",
        service: ["IT support", "Cleaning service", "Security monitoring"],
        writingMedia: ["Whiteboard", "Smart board", "Flip chart"]))
    }

    return decodableRooms
  }
}
