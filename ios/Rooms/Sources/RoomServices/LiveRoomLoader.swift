//
//  LiveRoomLoader.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

import Foundation
import Persistence
import RoomModels

// MARK: - RoomLoaderError

public enum RoomLoaderError: Error {
  case connectivity
  case noDataAvailable
  case malformedJSON, fileNotFound
  case persistenceError
  case alreadySeeded
}

// MARK: - RoomLoader

public protocol RoomLoader {
  func fetch(buildingId: String) -> Result<[Room], RoomLoaderError>
  func fetch() async -> Result<[Room], RoomLoaderError>
}

// MARK: - LiveRoomLoader

public final class LiveRoomLoader: RoomLoader {

  // MARK: Lifecycle

  public init(JSONBuildingLoader JSONRoomLoader: JSONRoomLoader, roomStatusLoader: RoomStatusLoader) {
    self.JSONRoomLoader = JSONRoomLoader
    self.roomStatusLoader = roomStatusLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Room], RoomLoaderError>

  public func fetch(buildingId: String) -> Result {
    if !hasSavedData {
      switch JSONRoomLoader.fetch() {
      case .success(let rooms):
        let filteredRooms = rooms.filter { $0.buildingId == buildingId }
        return .success(filteredRooms)

      case .failure(let err):
        return .failure(err)
      }
    } else {
      fatalError("Swift data not implemented")
    }
  }

  public func fetch() async -> Result {
    if !hasSavedData {
      switch JSONRoomLoader.fetch() {
      case .success(let rooms):
        await combineLiveAndSavedData(rooms)
      case .failure(let err):
        .failure(err)
      }
    } else {
      fatalError("Swift data not implemented")
    }
  }

  // MARK: Private

  private let JSONRoomLoader: JSONRoomLoader
  private let roomStatusLoader: RoomStatusLoader

  private var hasSavedData: Bool {
    UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedRoomsData)
  }

  private func combineLiveAndSavedData(_ rooms: [Room]) async -> Result {
    switch await roomStatusLoader.fetchRoomStatus() {
    case .success(let roomStatusResponse):
      let roomsWithStatus: [Room] = rooms.map { room in
        let roomStatus = roomStatusResponse[room.buildingId]?.roomStatuses[room.id]!

        return Room(
          abbreviation: room.abbreviation,
          accessibility: room.accessibility,
          audioVisual: room.audioVisual,
          buildingId: room.id,
          capacity: room.capacity,
          floor: room.floor,
          id: room.id,
          infoTechnology: room.infoTechnology,
          latitude: room.latitude,
          longitude: room.longitude,
          microphone: room.microphone,
          name: room.name,
          school: room.school,
          seating: room.seating,
          usage: room.usage,
          service: room.service,
          writingMedia: room.writingMedia,
          status: roomStatus!.status,
          endTime: roomStatus!.endtime)
      }

      return .success(rooms)

    case .failure(let failure):
      return .success(rooms)
    }
  }
}
