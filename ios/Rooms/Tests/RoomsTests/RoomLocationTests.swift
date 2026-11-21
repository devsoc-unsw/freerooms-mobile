//
//  RoomLocationTests.swift
//  Rooms
//
//  Created by Eric Wong on 21/11/2026.
//

import Location
import RoomModels
import Testing

struct RoomLocationTests {

  @Test("A room with coordinates has a location")
  func roomWithCoordinatesHasLocation() {
    // Given
    let room = Room.exampleOne

    // When
    let location = room.location

    // Then
    #expect(location == Location(latitude: room.latitude, longitude: room.longitude))
  }

  @Test("A room stored at 0, 0 has no location, so it falls back to its building")
  func roomWithoutCoordinatesHasNoLocation() {
    // Given
    let room = makeRoom("K-C27-250", in: "K-C27")

    // When
    let location = room.location

    // Then
    #expect(location == nil)
  }
}
