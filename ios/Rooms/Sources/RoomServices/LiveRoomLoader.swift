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
  func fetch(buildingId: String) async -> Result<[Room], RoomLoaderError>
  func fetch() async -> Result<[Room], RoomLoaderError>
}

// MARK: - LiveRoomLoader

public final class LiveRoomLoader: RoomLoader {

  // MARK: Lifecycle

  public init(JSONRoomLoader: JSONRoomLoader, roomStatusLoader: RoomStatusLoader, swiftDataRoomLoader: SwiftDataRoomLoader) {
    self.JSONRoomLoader = JSONRoomLoader
    self.roomStatusLoader = roomStatusLoader
    self.swiftDataRoomLoader = swiftDataRoomLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Room], RoomLoaderError>

  public func fetch(buildingId: String) async -> Result {
    if !hasSavedData {
      switch await JSONRoomLoader.fetch() {
      case .success(let rooms):
        var filteredRooms = rooms.filter { $0.buildingId == buildingId }
        await combineLiveAndSavedData(&filteredRooms)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSavedRoomsData)
        return .success(filteredRooms)

      case .failure(let err):
        return .failure(err)
      }
    } else {
      switch swiftDataRoomLoader.fetch() {
      case .success(let offlineRooms):
        var filteredRooms = offlineRooms.filter { $0.buildingId == buildingId }
        await combineLiveAndSavedData(&filteredRooms)
        return .success(filteredRooms)

      case .failure(let err):
        return .failure(err)
      }
    }
  }

  public func fetch() async -> Result {
    if !hasSavedData {
      switch await JSONRoomLoader.fetch() {
      case .success(var rooms):
        await combineLiveAndSavedData(&rooms)
        return .success(rooms)

      case .failure(let err):
        return .failure(err)
      }
    } else {
      switch swiftDataRoomLoader.fetch() {
      case .success(var offlineRooms):
        await combineLiveAndSavedData(&offlineRooms)
        return .success(offlineRooms)

      case .failure(let err):
        return .failure(err)
      }
    }
  }

  // MARK: Private

  private let JSONRoomLoader: JSONRoomLoader
  private let roomStatusLoader: RoomStatusLoader
  private let swiftDataRoomLoader: SwiftDataRoomLoader

  private var hasSavedData: Bool {
    UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedRoomsData)
  }

  private func combineLiveAndSavedData(_ rooms: inout [Room]) async {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if case .success(let roomStatusResponse) = await roomStatusLoader.fetchRoomStatus() {
      for i in rooms.indices {
        let roomStatus = roomStatusResponse[rooms[i].buildingId]?.roomStatuses[rooms[i].roomNumber] ?? RoomStatus(
          status: "",
          endtime: "")

        switch roomStatus.status {
        case "free":
          rooms[i].status = .available
        case "soon":
          rooms[i].status = .availableSoon
        case "busy":
          rooms[i].status = .unavailable
        default:
          rooms[i].status = .unknown
        }

        rooms[i].endTime = formatter.date(from: roomStatus.endtime)
      }
    }
  }
}
