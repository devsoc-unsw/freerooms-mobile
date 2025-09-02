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
}

// MARK: - RoomLoader

public protocol RoomLoader {
  func fetch(buildingId: String) -> Result<[Room], RoomLoaderError>
  func fetch() -> Result<[Room], RoomLoaderError>
}

// MARK: - LiveRoomLoader

public final class LiveRoomLoader: RoomLoader {

  // MARK: Lifecycle

  public init(JSONBuildingLoader JSONRoomLoader: JSONRoomLoader) {
    self.JSONRoomLoader = JSONRoomLoader
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

  public func fetch() -> Result {
    if !hasSavedData {
      switch JSONRoomLoader.fetch() {
      case .success(let rooms):
        .success(rooms)
      case .failure(let err):
        .failure(err)
      }
    } else {
      fatalError("Swift data not implemented")
    }
  }

  // MARK: Private

  private let JSONRoomLoader: JSONRoomLoader

  private var hasSavedData: Bool {
    UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedRoomsData)
  }

}
