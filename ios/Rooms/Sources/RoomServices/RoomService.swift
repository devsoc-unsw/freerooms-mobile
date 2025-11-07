//
//  RoomsService.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 5/8/2025.
//

import Foundation
import RoomModels

public typealias GetRoomResult = Swift.Result<[Room], FetchRoomError>
public typealias GetRoomBookingsResult = Swift.Result<[RoomBooking], FetchRoomError>

// MARK: - FetchRoomError

public enum FetchRoomError: Error, Equatable {
  case connectivity
  case invalidBuildingId
}

// MARK: - RoomService

public protocol RoomService {
  func getRooms() async -> GetRoomResult
  func getRooms(buildingId: String) async -> GetRoomResult
  func getRoomBookings(roomID: String) async -> GetRoomBookingsResult
  func forceReloadRooms() async
}

// MARK: - LiveRoomService

public final class LiveRoomService: RoomService {

  // MARK: Lifecycle

  public init(roomLoader: any RoomLoader, roomBookingLoader: any RoomBookingLoader) {
    self.roomLoader = roomLoader
    self.roomBookingLoader = roomBookingLoader
  }

  // MARK: Public

  public func getRooms(buildingId: String) async -> GetRoomResult {
    // Validate input
    guard !buildingId.isEmpty else {
      return .failure(.invalidBuildingId)
    }

    switch await roomLoader.fetch(buildingId: buildingId) {
    case .success(let rooms):
      return .success(rooms)
    case .failure:
      return .failure(.connectivity)
    }
  }

  public func getRooms() async -> GetRoomResult {
    switch await roomLoader.fetch() {
    case .success(let rooms):
      .success(rooms)
    case .failure:
      .failure(.connectivity)
    }
  }

  public func getRoomBookings(roomID: String) async -> GetRoomBookingsResult {
    switch await roomBookingLoader.fetch(bookingsOf: roomID) {
    case .success(let roomBookings):
      .success(roomBookings)
    case .failure:
      .failure(.connectivity)
    }
  }

  public func forceReloadRooms() async {
    _ = await roomLoader.fetch()
  }

  // MARK: Private

  private var roomLoader: any RoomLoader
  private var roomBookingLoader: any RoomBookingLoader
}

// MARK: - PreviewRoomService

public final class PreviewRoomService: RoomService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getRoomBookings(roomID _: String) async -> GetRoomBookingsResult {
    .success([
      RoomBooking(
        bookingType: "MISC",
        end: ISO8601DateFormatter().date(from: "2024-01-02T10:30:00+00:00")!,
        name: "COMM",
        start: ISO8601DateFormatter().date(from: "2024-01-01T20:00:00+00:00")!),
    ])
  }

  public func getRooms() async -> GetRoomResult {
    .success([Room.exampleOne, Room.exampleTwo])
  }

  public func getRooms(buildingId _: String) async -> GetRoomResult {
    .success([Room.exampleOne, Room.exampleTwo])
  }

  public func forceReloadRooms() async {
    // No-op for preview
  }
}
