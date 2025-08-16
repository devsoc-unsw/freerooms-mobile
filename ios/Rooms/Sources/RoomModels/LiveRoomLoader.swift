//
//  LiveRoomLoader.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

import Foundation

// MARK: - LiveRoomLoader

public final class LiveRoomLoader: RoomLoader {

  // MARK: Lifecycle

  public init(remoteRoomLoader: any RemoteRoomLoader) {
    self.remoteRoomLoader = remoteRoomLoader
  }

  // MARK: Public

  public func fetch(buildingId: String) async -> Result<[Room], RoomLoaderError> {
    switch await remoteRoomLoader.fetch(buildingId: buildingId) {
    case .success(let remoteRooms):
      let rooms = remoteRooms.map { remoteRoom in
        Room(
          name: remoteRoom.name,
          id: remoteRoom.id,
          abbreviation: remoteRoom.abbreviation,
          capacity: remoteRoom.capacity,
          usage: remoteRoom.usage,
          school: remoteRoom.school)
      }
      return .success(rooms)

    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private let remoteRoomLoader: any RemoteRoomLoader
}
