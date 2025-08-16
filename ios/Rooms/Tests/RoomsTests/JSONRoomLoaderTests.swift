//
//  LiveJSONRoomLoaderTests.swift
//  Rooms
//
//  Created by Chris Wong on 5/8/2025.
//

import RoomModels
@testable import RoomServices
import Persistence
import Testing

struct LiveJSONRoomLoaderTests {

  // MARK: Internal
  
  @Test("Rooms Seed JSON is bundled")
  func RoomsSeedJSONIsBundled() {
    // Given
    let decodableRooms = createDecodableRooms(0)
    let mockJSONLoader = MockJSONLoader(loads: decodableRooms)
    let sut = LiveJSONRoomLoader(using: mockJSONLoader)
    
    // When
    let roomsSeedJSONPath = sut.roomsSeedJSONPath
    
    // Then
    if roomsSeedJSONPath == nil {
      
    }
  }

  @Test("JSON room loader successfully decodes JSON into type [Room] for zero DecodableRooms")
  func JSONRoomLoaderLoadsJSONForZeroDecodableRoom() {
    // Given
    let decodableRooms = createDecodableRooms(0)
    let mockJSONLoader = MockJSONLoader(loads: decodableRooms)
    // When

    // Then
  }
  
  @Test("JSON room loader successfully decodes JSON into type [Room] for 1 DecodableRooms")
  func JSONRoomLoaderLoadsJSONForOneDecodableRoom() {
    // Given
    let decodableRooms = createDecodableRooms(1)
    let mockJSONLoader = MockJSONLoader(loads: decodableRooms)
    
    // When

    // Then
  }
  
  @Test("JSON room loader successfully decodes JSON into type [Room] for 10 DecodableRooms")
  func JSONRoomLoaderLoadsJSONForTenDecodableRooms() {
    // Given
    let decodableRooms = createDecodableRooms(10)
    let mockJSONLoader = MockJSONLoader(loads: decodableRooms)
    
    // When

    // Then
  }

  @Test("JSON room loader successfully decodes empty JSON into type [Room]")
  func JSONRoomLoaderDecodesEmptyJSON() {
    // Given

    // When

    // Then
  }

  @Test("JSON room loader throws error when given malformed JSON")
  func JSONRoomLoaderThrowsMalformedJSONError() {
    // Given

    // When

    // Then
  }

  @Test("JSON room loader throws error when given invalid file path")
  func JSONRoomLoaderThrowsErrorOnInvalidFilePath() {
    // Given

    // When

    // Then
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
    for i in 0..<count {
      decodableRooms.append(DecodableRoom(
        abbr: "SCI101",
        accessibility: "Wheelchair accessible, hearing loop available",
        audiovisual: "Projector, speakers, HDMI connection",
        buildingId: "BLDG-2024-007",
        capacity: 45,
        floor: "Ground floor",
        id: "ROOM-12345-ABC",
        lat: 40.7589,
        long: -73.9851,
        microphone: ["Wireless handheld", "Lapel mic", "Desktop mic"],
        name: "Science Lecture Hall A",
        school: "Metropolitan University",
        seating: "Theater-style fixed seating",
        usage: "Lectures, presentations, seminars",
        service: ["IT support", "Cleaning service", "Security monitoring"],
        writingMedia: ["Whiteboard", "Smart board", "Flip chart"]
    ))
    }
    
    return decodableRooms
  }
  
  private func createRooms(_ count: Int) -> [Room] {
    var rooms: [Room] = []
    for i in 0..<count {
      rooms.append(Room(
        abbr: "SCI101",
        accessibility: "Wheelchair accessible, hearing loop available",
        audiovisual: "Projector, speakers, HDMI connection",
        buildingId: "BLDG-2024-007",
        capacity: 45,
        floor: "Ground floor",
        id: "ROOM-12345-ABC",
        lat: 40.7589,
        long: -73.9851,
        microphone: ["Wireless handheld", "Lapel mic", "Desktop mic"],
        name: "Science Lecture Hall A",
        school: "Metropolitan University",
        seating: "Theater-style fixed seating",
        usage: "Lectures, presentations, seminars",
        service: ["IT support", "Cleaning service", "Security monitoring"],
        writingMedia: ["Whiteboard", "Smart board", "Flip chart"]
    ))
    }
    
    return rooms
  }
}
