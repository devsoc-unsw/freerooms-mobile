//
//  RoomInteractor.swift
//  Rooms
//
//  Created by Yanlin Li  on 3/9/2025.
//
import Foundation
import Location
import RoomModels
import RoomServices

public class RoomInteractor {

  // MARK: Lifecycle

  public init(roomService: RoomService, locationService: LocationService) {
    self.roomService = roomService
    self.locationService = locationService
  }

  // MARK: Public

  // TODO: fix until booking are done
  public struct RoomBooking {
    public var name: String
    public var room: Room
    public var bookingType: String
    public var startTime: String
    public var endTime: String
  }

  public func getRoomsSortedAlphabetically(rooms: [Room], inAscendingOrder: Bool) -> [Room] {
    rooms.sorted { a, b in
      inAscendingOrder ? a.name < b.name : a.name > b.name
    }
  }

  public func getRoomsSortedAlphabetically(inAscendingOrder: Bool) -> Result<[Room], Error> {
    switch roomService.getRooms() {
    case .success(let rooms):
      let sorted = getRoomsSortedAlphabetically(rooms: rooms, inAscendingOrder: inAscendingOrder)
      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomsFilteredAlphabeticallyByBuildingId(buildingId: String, inAscendingOrder: Bool) -> Result<[Room], Error> {
    switch roomService.getRooms(buildingId: buildingId) {
    case .success(let rooms):
      let result = rooms
        .filter { $0.buildingId == buildingId }
        .sorted { a, b in
          inAscendingOrder ? a.name < b.name : a.name > b.name
        }
      return .success(result)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomsFilteredByRoomType(usage roomType: String) -> Result<[Room], Error> {
    switch roomService.getRooms() {
    case .success(let rooms):
      let filtered = rooms.filter { $0.usage == roomType }
      return .success(filtered)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomsFilteredByCampusSection(_ campusSection: CampusSection) -> Result<[Room], Error> {
    switch roomService.getRooms() {
    case .success(let rooms):
      let filtered = rooms.filter { $0.gridReference.campusSection == campusSection }
      return .success(filtered)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomsFilteredByDuration(for minDuration: Int) -> Result<[Room], Error> {
    switch roomService.getRooms() {
    case .success(let rooms):
      var result: [Room] = []
      for room in rooms {
        let currentTime = Date().formatted()
        let mockRoomBookings = [
          RoomBooking(
            name: "LAWS1052 LEC",
            room: Room.exampleOne,
            bookingType: "CLASS",
            startTime: "2024-02-29T03:00:00+00:00",
            endTime: "2024-02-29T05:00:00+00:00"),
          RoomBooking(
            name: "LAWS1052 LEC",
            room: Room.exampleTwo,
            bookingType: "CLASS",
            startTime: "2024-02-29T06:00:00+00:00",
            endTime: "2024-02-29T07:00:00+00:00"),
        ]

        // Sort classes by start time, then end time.
//        let classBookings = roomService.getRoomBooking(room.id)
        let classBookings = mockRoomBookings
          .filter { $0.room == room }
          .sorted { $0.startTime < $1.startTime }
          .sorted { $0.endTime < $1.endTime }

        // Find the first class that *ends* after the current time
        // Current time should be changing every 15 or 30 min now and then
        let firstClassEndsAfterCurrentTime: RoomBooking? = classBookings.first { $0.endTime >= currentTime }
        if firstClassEndsAfterCurrentTime == nil {
          // class is free indefinitely meaning it is free the whole day from current time onwards
          result.append(room)
          continue
        }

        /// Check if from current time to the next first class duration satisfy minDuration
        let start = firstClassEndsAfterCurrentTime!.startTime
        if currentTime < start {
          let isoFormat = ISO8601DateFormatter()
          let startTimeInDateFormat = isoFormat.date(from: firstClassEndsAfterCurrentTime!.startTime)!
          let currentTimeInDateFormat = isoFormat.date(from: currentTime)!
          let duration = startTimeInDateFormat.timeIntervalSince(currentTimeInDateFormat) // in seconds
          let durationInMinutes = Int(duration / 60)

          if durationInMinutes >= minDuration {
            result.append(room)
          }
        }
      }

      return .success(result)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomsFilteredByAllBuildingId(buildingIds: [String]) -> Result<[String: [Room]], Error> {
    switch roomService.getRooms() {
    case .success(let rooms):
      var result: [String: [Room]] = [:]
      for id in buildingIds {
        let filteredRooms: [Room] = rooms.filter { $0.buildingId == id }
        result[id] = filteredRooms
      }
      return .success(result)

    case .failure(let error):
      return .failure(error)
    }
  }

  // MARK: Private

  private let roomService: RoomService
  private let locationService: LocationService
}
