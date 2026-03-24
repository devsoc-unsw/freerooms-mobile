//
//  RoomService.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 5/8/2025.
//

import Foundation
import RoomModels
import VISOR

public typealias GetRoomResult = Swift.Result<[Room], FetchRoomError>
public typealias GetRoomBookingsResult = Swift.Result<[RoomBooking], FetchRoomError>
public typealias GetRoomRatingResult = Swift.Result<RoomRating, FetchRoomError>

// MARK: - FetchRoomError

public enum FetchRoomError: Error, Equatable {
  case connectivity
  case invalidBuildingId
  case invalidRoomID
  case invalidURL
}

extension FetchRoomError {
  public var clientMessage: String {
    switch self {
    case .connectivity:
      "Failed to fetch rooms. Please check your internet connection."
    case .invalidBuildingId:
      "Invalid building ID provided."
    case .invalidRoomID:
      "Invalid room ID provided."
    case .invalidURL:
      "API URL doesn't exist."
    }
  }
}

// MARK: - RoomService

@Stubbable
public protocol RoomService {
  func getRooms() async -> GetRoomResult
  func getRooms(buildingId: String) async -> GetRoomResult
  func getRoomBookings(roomID: String) async -> GetRoomBookingsResult
  func getRoomRating(roomID: String) async -> GetRoomRatingResult
}

// MARK: - LiveRoomService

public final class LiveRoomService: RoomService {

  // MARK: Lifecycle

  public init(roomLoader: any RoomLoader, roomBookingLoader: any RoomBookingLoader, roomRatingLoader: any RoomRatingLoader) {
    self.roomLoader = roomLoader
    self.roomBookingLoader = roomBookingLoader
    self.roomRatingLoader = roomRatingLoader
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

  public func getRoomRating(roomID: String) async -> GetRoomRatingResult {
    switch await roomRatingLoader.fetchRoomRating(roomID: roomID) {
    case .success(let rating):
      .success(rating)
    case .failure(let error):
      switch error {
      case .invalidRoomID:
        .failure(.invalidRoomID)
      case .invalidURL:
        .failure(.invalidURL)
      case .connectivity:
        .failure(.connectivity)
      }
    }
  }

  // MARK: Private

  private var roomLoader: any RoomLoader
  private var roomBookingLoader: any RoomBookingLoader
  private var roomRatingLoader: any RoomRatingLoader
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

  public func getRoomRating(roomID _: String) async -> GetRoomRatingResult {
    .success(RoomRating(
      roomId: "K-J17-G03",
      overallRating: 4.0,
      averageRating: AverageRating(cleanliness: 5.0, location: 5.0, quietness: 4.0)))
  }
}
