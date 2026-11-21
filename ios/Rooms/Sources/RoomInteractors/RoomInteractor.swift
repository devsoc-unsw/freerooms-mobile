//
//  RoomInteractor.swift
//  Rooms
//
//  Created by Yanlin Li  on 3/9/2025.
//

import Foundation
public import Location
public import RoomModels
public import RoomServices

public class RoomInteractor {

  // MARK: Lifecycle

  public init(roomService: any RoomService, favouriteService: any FavoriteRoomService) {
    self.roomService = roomService
    self.favouriteService = favouriteService
  }

  // MARK: Public

  public func getRoomsSortedAlphabetically(rooms: [Room], inAscendingOrder: Bool) -> [Room] {
    rooms.sorted { Self.isOrderedByName($0, $1, inAscendingOrder: inAscendingOrder) }
  }

  /// How far `userLocation` is from each room, in metres, keyed by room ID. A room without
  /// coordinates uses its building's distance from `buildingDistances` (keyed by building ID),
  /// or is left out.
  public func getRoomDistances(
    _ rooms: [Room],
    from userLocation: Location,
    buildingDistances: [String: Double])
    -> [String: Double]
  {
    var distances = [String: Double]()
    for room in rooms {
      if let roomLocation = room.location {
        distances[room.id] = userLocation.distance(to: roomLocation)
      } else if let buildingDistance = buildingDistances[room.buildingId] {
        distances[room.id] = buildingDistance
      }
    }
    return distances
  }

  /// Sorts rooms nearest first, or furthest first when not ascending. Rooms the same distance
  /// away go A–Z, and rooms without a distance go last.
  public func getRoomsSortedByDistance(
    _ rooms: [Room],
    distanceByRoomID: [String: Double],
    inAscendingOrder: Bool)
    -> [Room]
  {
    rooms.sorted { a, b in
      switch (distanceByRoomID[a.id], distanceByRoomID[b.id]) {
      case (let aDistance?, let bDistance?) where aDistance != bDistance:
        inAscendingOrder ? aDistance < bDistance : aDistance > bDistance
      case (_?, nil):
        true
      case (nil, _?):
        false
      default:
        Self.isOrderedByName(a, b, inAscendingOrder: true)
      }
    }
  }

  public func filterRoomsByQueryString(_ rooms: [Room], by searchText: String) -> [Room] {
    guard !searchText.isEmpty else { return rooms }
    let loweredQuery = searchText.lowercased()
    return rooms.filter {
      $0.name.lowercased().contains(loweredQuery) ||
        $0.abbreviation.lowercased().contains(loweredQuery)
    }
  }

  /// Every room, in the order the service returns them.
  public func getRooms() async -> GetRoomResult {
    await roomService.getRooms()
  }

  public func getRoomsFilteredAlphabeticallyByBuildingId(
    buildingId: String,
    inAscendingOrder: Bool)
    async -> Result<[Room], FetchRoomError>
  {
    switch await roomService.getRooms(buildingId: buildingId) {
    case .success(let rooms):
      let roomsInBuilding = rooms.filter { $0.buildingId == buildingId }
      return .success(getRoomsSortedAlphabetically(rooms: roomsInBuilding, inAscendingOrder: inAscendingOrder))

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

  public func getFilteredRooms(options: FilterRoomOptions) async -> Result<[Room], FetchRoomError> {
    switch await roomService.getFilterRooms(options: options) {
    case .success(let rooms):
      .success(rooms)
    case .failure(let error):
      .failure(error)
    }
  }

  public func applyClientSideFilters(
    rooms: [Room],
    campusLocation: CampusLocation?,
    amenities: Set<RoomAmenity> = [])
    -> [Room]
  {
    rooms.filter { room in
      guard amenities.allSatisfy({ $0.isAvailable(in: room) }) else { return false }
      guard let campusLocation else { return true }
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

  public func toggleFavorite(roomID: Room.ID) {
    if favouriteService.isFavorite(roomID: roomID) {
      favouriteService.removeFavorite(roomID: roomID)
    } else {
      favouriteService.addFavorite(roomID: roomID)
    }
  }

  public func isFavorite(roomID: Room.ID) -> Bool {
    favouriteService.isFavorite(roomID: roomID)
  }

  public func getAllFavoriteRoomIds() -> [Room.ID] {
    favouriteService.getAllFavoriteRoomIds()
  }

  // MARK: Private

  private let roomService: any RoomService
  private let favouriteService: any FavoriteRoomService

  /// Whether `a` comes before `b` by name, A–Z or Z–A. The one place rooms are compared by name.
  /// Uses the same natural order as buildings (`Building.SortOptions.alphabetical`), so G9 comes
  /// before G10.
  private static func isOrderedByName(_ a: Room, _ b: Room, inAscendingOrder: Bool) -> Bool {
    a.name.localizedStandardCompare(b.name) == (inAscendingOrder ? .orderedAscending : .orderedDescending)
  }
}
