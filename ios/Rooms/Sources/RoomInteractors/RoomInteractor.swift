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

  /// Per-room bookings keyed by `Room.id`.
  public func getRoomsFilteredByDuration(
    for minDuration: Int,
    roomBookings: [String: [RoomBooking]],
    rooms: [Room],
    now: Date = Date())
    -> [Room]
  {
    roomsFreeForMinimumDuration(
      minDurationMinutes: minDuration,
      now: now,
      rooms: rooms,
      bookingsForRoom: { room in roomBookings[room.id] ?? [] })
  }

  public func getRoomsFilteredByAllBuildingId() async -> Result<[String: [Room]], FetchRoomError> {
    let buildingIds =
      [
        "K-G27",
        "K-J17",
        "K-H13",
        "K-E26",
        "K-D26",
        "K-G6",
        "K-E12",
        "K-H20",
        "K-B16",
        "K-K17",
        "K-F12",
        "K-G17",
        "K-D8",
        "K-D16",
        "K-F25",
        "K-F31",
        "K-F20",
        "K-G19",
        "K-F10",
        "K-J14",
        "K-F8",
        "K-F21",
        "K-E10",
        "K-F23",
        "K-D23",
        "K-C20",
        "K-J12",
        "K-K15",
        "K-E19",
        "K-K14",
        "K-E15",
        "K-F17",
        "K-M15",
        "K-E8",
        "K-F13",
        "K-C24",
        "K-E4",
        "K-H6",
        "K-H22",
        "K-C27",
        "K-G14",
        "K-G15",
        "K-J18",
      ]

    switch await roomService.getRooms() {
    case .success(let rooms):
      var result = [String: [Room]]()
      for id in buildingIds {
        let filteredRooms: [Room] = rooms.filter { $0.buildingId == id }
        result[id] = filteredRooms
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

  /// - Parameter roomBookingsByRoomId: Bookings keyed by `Room.id` for duration filtering. Rooms with no entry are treated as having no known bookings (they pass the duration filter until loaded).
  public func applyFilters(rooms: [Room], filter: RoomFilter, roomBookingsByRoomId: [String: [RoomBooking]]) -> [Room] {
    var filteredRooms = rooms

    // Filter by room type (usage)
    if !filter.selectedRoomTypes.isEmpty {
      filteredRooms = filteredRooms.filter { room in
        let roomType = RoomType(rawValue: room.usage)
        return roomType.map { filter.selectedRoomTypes.contains($0) } ?? false
      }
    }

    // Filter by capacity
    if let capacity = filter.selectedCapacity {
      filteredRooms = filteredRooms.filter { $0.capacity >= capacity }
    }

    // Filter by campus location
    if let campusLocation = filter.selectedCampusLocation {
      filteredRooms = filteredRooms.filter { room in
        let gridReference = GridReference.fromBuildingID(buildingID: room.buildingId)
        switch campusLocation {
        case .upper:
          return gridReference.campusSection == .upper
        case .middle:
          return gridReference.campusSection == .middle
        case .lower:
          return gridReference.campusSection == .lower
        }
      }
    }

    // Date/time chosen in the filter sheet (when not default) is the start of the duration window; see `RoomFilter.filteringReferenceInstant`.
    let referenceInstant = filter.filteringReferenceInstant()

    if let duration = filter.selectedDuration {
      filteredRooms = getRoomsFilteredByDuration(
        for: duration.rawValue,
        roomBookings: roomBookingsByRoomId,
        rooms: filteredRooms,
        now: referenceInstant)
    }

    return filteredRooms
  }

  // MARK: Private

  /// A booking blocks the room if it overlaps the interval from `now` for `minDurationMinutes`.
  private func roomsFreeForMinimumDuration(
    minDurationMinutes: Int,
    now: Date,
    rooms: [Room],
    bookingsForRoom: (Room) -> [RoomBooking])
    -> [Room]
  {
    let windowEnd = now.addingTimeInterval(TimeInterval(minDurationMinutes * 60))
    return rooms.filter { room in
      let bookings = bookingsForRoom(room)
      let hasBlockingBooking = bookings.contains { booking in
        booking.start < windowEnd && booking.end > now
      }
      return !hasBlockingBooking
    }
  }

  private let roomService: RoomService
  private let locationService: LocationService
}
