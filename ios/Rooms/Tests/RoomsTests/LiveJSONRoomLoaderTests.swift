//
//  LiveJSONRoomLoaderTests.swift
//  Rooms
//
//  Created by Chris Wong on 5/8/2025.
//

import Testing
import Rooms

struct LiveJSONRoomLoaderTests {
  @Test("JSON room loader successfully decodes JSON into type [Room]")
  func JSONRoomLoaderLoadsJSON() {
    // Given
    
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
  func JSONRoomLoaderThrowsErrorOnInvalidFilePath()  {
    // Given
    
    // When
    
    // Then
  }
  
  private func expect(_ res: LiveJSONRoomLoader.Result, toThrow expected: JSONRoomLoaderError) {
    switch res {
    case .failure(let error):
      #expect(checkErrorEquals(error, equals: expected, as: LiveJSONRoomLoader.self) == true)
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
//    for _ in 0..<count {
//      decodableBuildings.append(DecodableBuilding(name: "name", id: "123", lat: 1.0, long: 1.0, aliases: ["A", "B"]))
//    }
    return decodableRooms
  }

  private func createRooms(_ count: Int) -> [Room] {
    var rooms: [Room] = []
//    for _ in 0..<count {
//      buildings.append(Building(name: "name", id: "123", latitude: 1.0, longitude: 1.0, aliases: ["A", "B"]))
//    }
    return rooms
  }
}
