//
//  Helpers.swift
//  Rooms
//
//  Created by Chris Wong on 1/9/2025.
//

import RoomModels

func createRooms(_ count: Int) -> [Room] {
  var rooms: [Room] = []
  for _ in 0..<count {
    rooms.append(Room(
      abbreviation: "SCI101",
      accessibility: "Wheelchair accessible, hearing loop available",
      audioVisual: "Projector, speakers, HDMI connection",
      buildingId: "BLDG-2024-007",
      capacity: 45,
      floor: "Ground floor",
      id: "ROOM-12345-ABC",
      latitude: 40.7589,
      longitude: -73.9851,
      microphone: ["Wireless handheld", "Lapel mic", "Desktop mic"],
      name: "Science Lecture Hall A",
      school: "Metropolitan University",
      seating: "Theater-style fixed seating",
      usage: "Lectures, presentations, seminars",
      service: ["IT support", "Cleaning service", "Security monitoring"],
      writingMedia: ["Whiteboard", "Smart board", "Flip chart"]))
  }

  return rooms
}

func createSwiftDataRooms(_ count: Int) -> [SwiftDataRoom] {
  var rooms: [SwiftDataRoom] = []
  for _ in 0..<count {
    rooms.append(SwiftDataRoom(
      abbreviation: "SCI101",
      accessibility: "Wheelchair accessible, hearing loop available",
      audioVisual: "Projector, speakers, HDMI connection",
      buildingId: "BLDG-2024-007",
      capacity: 45,
      floor: "Ground floor",
      id: "ROOM-12345-ABC",
      latitude: 40.7589,
      longitude: -73.9851,
      microphone: ["Wireless handheld", "Lapel mic", "Desktop mic"],
      name: "Science Lecture Hall A",
      school: "Metropolitan University",
      seating: "Theater-style fixed seating",
      usage: "Lectures, presentations, seminars",
      service: ["IT support", "Cleaning service", "Security monitoring"],
      writingMedia: ["Whiteboard", "Smart board", "Flip chart"]))
  }

  return rooms
}
