//
//  RoomsService.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 5/8/2025.
//

import Foundation
import RoomModels

public typealias GetRoomResult = Swift.Result<[Room], FetchRoomError>

// MARK: - FetchRoomError

public enum FetchRoomError: Error, Equatable {
  case connectivity
  case invalidBuildingId
}

// MARK: - RoomService

public protocol RoomService {
  func getRooms() -> GetRoomResult
  func getRooms(buildingId: String) -> GetRoomResult
}

// MARK: - LiveRoomService

public final class LiveRoomService: RoomService {

  // MARK: Lifecycle

  public init(roomLoader: any RoomLoader) {
    self.roomLoader = roomLoader
  }

  // MARK: Public

  public typealias GetRoomResult = Swift.Result<[Room], FetchRoomError>

  public func getRooms(buildingId: String) -> GetRoomResult {
    // Validate input
    guard !buildingId.isEmpty else {
      return .failure(.invalidBuildingId)
    }

    switch roomLoader.fetch(buildingId: buildingId) {
    case .success(let rooms):
      return .success(rooms)
    case .failure:
      return .failure(.connectivity)
    }
  }

  public func getRooms() -> GetRoomResult {
    // swiftlint:disable:next no_direct_standard_out_logs
    print("hi im in getRooms service")

    switch roomLoader.fetch() {
    case .success(let rooms):
      return .success(rooms)
    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private var roomLoader: any RoomLoader
}

// MARK: - PreviewRoomService

public final class PreviewRoomService: RoomService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getRooms() -> GetRoomResult {
    .success([Room.exampleOne, Room.exampleTwo])
  }

  public func getRooms(buildingId _: String) -> GetRoomResult {
    .success([Room.exampleOne, Room.exampleTwo])
  }
}
