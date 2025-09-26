//
//  RoomSearchInteractor.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 25/9/2025.
//

import Foundation
import RoomModels
import RoomServices

// MARK: - RoomSearchInteractor

public protocol RoomSearchInteractor {
  func filterRooms(by searchString: String) async -> Result<[Room], Error>
}

// MARK: - LiveRoomSearchInteractor

public final class LiveRoomSearchInteractor: RoomSearchInteractor {

  // MARK: Lifecycle

  public init(roomService: RoomService) {
    self.roomService = roomService
  }

  // MARK: Public

  public func filterRooms(by searchString: String) async -> Result<[Room], Error> {
    switch await roomService.getRooms() {
    case .success(let rooms):
      let filteredRooms = filterRoomsByString(rooms: rooms, searchString: searchString)
      return .success(filteredRooms)

    case .failure(let error):
      return .failure(error)
    }
  }

  // MARK: Private

  private let roomService: RoomService

  private func filterRoomsByString(rooms: [Room], searchString: String) -> [Room] {
    // If search string is empty, return all rooms
    guard !searchString.isEmpty else {
      return rooms
    }

    // Filter rooms that contain the search string (case-insensitive)
    return rooms.filter { room in
      room.name.lowercased().contains(searchString.lowercased())
    }
  }
}
