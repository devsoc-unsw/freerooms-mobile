//
//  Helpers.swift
//  Rooms
//
//  Created by Chris Wong on 1/9/2025.
//

import Foundation
import RoomModels

func createRooms(_ count: Int) -> [Room] {
  var rooms: [Room] = []
  for _ in 0..<count {
    rooms.append(Room(
      abbreviation: "SCI101",
      accessibility: ["Wheelchair accessible", "hearing loop available"],
      audioVisual: ["Projector", "speakers", "HDMI connection"],
      buildingId: "BLDG-2024-007",
      capacity: 45,
      floor: "Ground floor",
      id: "ROOM-12345-ABC",
      infoTechnology: [],
      latitude: 40.7589,
      longitude: -73.9851,
      microphone: ["Wireless handheld", "Lapel mic", "Desktop mic"],
      name: "Science Lecture Hall A",
      school: "Metropolitan University",
      seating: "Theater-style fixed seating",
      usage: "LCTR",
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
      accessibility: ["Wheelchair accessible", "hearing loop available"],
      audioVisual: ["Projector", "speakers", "HDMI connection"],
      buildingId: "BLDG-2024-007",
      capacity: 45,
      floor: "Ground floor",
      id: "ROOM-12345-ABC",
      infoTechnology: [],
      latitude: 40.7589,
      longitude: -73.9851,
      microphone: ["Wireless handheld", "Lapel mic", "Desktop mic"],
      name: "Science Lecture Hall A",
      school: "Metropolitan University",
      seating: "Theater-style fixed seating",
      usage: "LCTR",
      service: ["IT support", "Cleaning service", "Security monitoring"],
      writingMedia: ["Whiteboard", "Smart board", "Flip chart"],
      status: nil,
      endTime: nil))
  }

  return rooms
}

func createRemoteRoomBookings(_ count: Int) -> [RemoteRoomBooking] {
  var bookings: [RemoteRoomBooking] = []
  for _ in 0..<count {
    bookings.append(RemoteRoomBooking(
      bookingType: "MISC",
      end: "2024-01-02T10:30:00.000+00:00",
      name: "COMM",
      start: "2024-01-01T20:00:00.000+00:00"))
  }

  return bookings
}

func createRoomBookings(_ count: Int) -> [RoomBooking] {
  var bookings: [RoomBooking] = []
  for _ in 0..<count {
    bookings.append(RoomBooking(
      bookingType: "MISC",
      end: ISO8601DateFormatter().date(from: "2024-01-02T10:30:00+00:00")!,
      name: "COMM",
      start: ISO8601DateFormatter().date(from: "2024-01-01T20:00:00+00:00")!))
  }

  return bookings
}

func createRoomBookingsFromStartToEnd(_ count: Int, from start: Date, to end: Date) -> [RoomBooking] {
  var bookings: [RoomBooking] = []
  for _ in 0..<count {
    bookings.append(RoomBooking(
      bookingType: "MISC",
      end: end,
      name: "COMM",
      start: start))
  }

  return bookings
}

func createRemoteRoomStatus(_ count: Int) -> RemoteRoomStatus {
  var buildingStatuses: RemoteRoomStatus = [:]

  for _ in 0..<count {
    buildingStatuses["BLDG-2024-007"] = BuildingRoomStatus(numAvailable: 8,
                                                           roomStatuses: ["ROOM-12345-ABC": RoomStatus(status: "", endtime: "")])
  }

  return buildingStatuses
}
