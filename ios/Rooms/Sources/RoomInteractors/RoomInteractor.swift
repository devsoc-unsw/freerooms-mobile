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

  public func getRoomsSortedAlphabetically(rooms: [Room], inAscendingOrder: Bool) -> [Room] {
    rooms.sorted { a, b in
      inAscendingOrder ? a.name < b.name : a.name > b.name
    }
  }

  public func filterRoomsByQueryString(_ rooms: [Room], by searchText: String) -> [Room] {
    guard !searchText.isEmpty else { return rooms }
    let loweredQuery = searchText.lowercased()
    return rooms.filter { $0.name.lowercased().contains(loweredQuery) }
  }

  public func getRoomsSortedAlphabetically(inAscendingOrder: Bool) async -> Result<[Room], FetchRoomError> {
    switch await roomService.getRooms() {
    case .success(let rooms):
      let sorted = getRoomsSortedAlphabetically(rooms: rooms, inAscendingOrder: inAscendingOrder)
      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomsFilteredAlphabeticallyByBuildingId(
    buildingId: String,
    inAscendingOrder: Bool)
    async -> Result<[Room], FetchRoomError>
  {
    switch await roomService.getRooms(buildingId: buildingId) {
    case .success(let rooms):
      let result =
        rooms
          .filter { $0.buildingId == buildingId }
          .sorted { a, b in
            inAscendingOrder ? a.name < b.name : a.name > b.name
          }
      return .success(result)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomsFilteredByRoomType(usage roomType: String) async -> Result<[Room], FetchRoomError> {
    switch await roomService.getRooms() {
    case .success(let rooms):
      let filtered = rooms.filter { $0.usage == roomType }
      return .success(filtered)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomsFilteredByCampusSection(_ campusSection: CampusSection) async -> Result<[Room], FetchRoomError> {
    switch await roomService.getRooms() {
    case .success(let rooms):
      let filtered = rooms.filter {
        GridReference.fromBuildingID(buildingID: $0.buildingId).campusSection == campusSection
      }
      return .success(filtered)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomsFilteredByDuration(
    for minDuration: Int,
    roomBookings: [String: [RoomBooking]])
    async -> Result<[Room], FetchRoomError>
  {
    switch await roomService.getRooms() {
    case .success(let rooms):
      var result = [Room]()
      for room in rooms {
        let currentTime = Date()

        // Sort classes by start time, then end time.
        let classBookings: [RoomBooking] =
          roomBookings[room.id]
            ?? []
            .sorted { $0.start < $1.start }
            .sorted { $0.end < $1.end }

        // Find the first class that *ends* after the current time
        // Current time should be changing every 15 or 30 min now and then
        let firstClassEndsAfterCurrentTime: RoomBooking? = classBookings.first {
          $0.end >= currentTime
        }
        if firstClassEndsAfterCurrentTime == nil {
          // class is free indefinitely meaning it is free the whole day from current time onwards
          result.append(room)
          continue
        }

        /// Check if from current time to the next first class duration satisfy minDuration
        let start = firstClassEndsAfterCurrentTime!.start
        if currentTime < start {
          let duration = start.timeIntervalSince(currentTime) // in seconds
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

  public func getRoomsFilteredByAllBuildingId() async -> Result<[String: [Room]], FetchRoomError> {
		switch await roomService.getRooms() {
    case .success(let rooms):
      var result = [String: [Room]]()
      for room in rooms {
				result[room.buildingId, default: []].append(room)
      }
      return .success(result)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getRoomBookings(roomID: String) async -> Result<[RoomBooking], FetchRoomError> {
    switch await roomService.getRoomBookings(roomID: roomID) {
    case .success(let success):
      .success(success)
    case .failure(let error):
      .failure(error)
    }
  }

  public func getRoomRating(roomID: String) async -> Result<RoomRating, FetchRoomError> {
    switch await roomService.getRoomRating(roomID: roomID) {
    case .success(let rating):
      .success(rating)
    case .failure(let error):
      .failure(error)
    }
  }

  // MARK: Private

  private let roomService: RoomService
  private let locationService: LocationService
}
