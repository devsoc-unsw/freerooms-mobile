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
  func getRooms() async -> GetRoomResult
  func getRooms(buildingId: String) async -> GetRoomResult
}

// MARK: - LiveRoomService

public final class LiveRoomService: RoomService {

  // MARK: Lifecycle

  public init(roomLoader: any RoomLoader) {
    self.roomLoader = roomLoader
  }

  // MARK: Public

  public typealias GetRoomResult = Swift.Result<[Room], FetchRoomError>

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

  // MARK: Private

  private var roomLoader: any RoomLoader
}

// MARK: - RoomLoader

// MARK: - RoomLoaderError
