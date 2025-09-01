//
//  MockJSONRoomLoader.swift
//  Rooms
//
//  Created by Chris Wong on 1/9/2025.
//

import RoomModels
import RoomServices

struct MockJSONRoomLoader: JSONRoomLoader {
  func fetch() -> Result<[RoomModels.Room], RoomServices.RoomLoaderError> {
    if let error {
      return .failure(error)
    }
    return .success(rooms)
  }

  let error: RoomLoaderError?
  let rooms: [Room]

  public init(throws error: RoomLoaderError? = nil, loads rooms: [Room] = []) {
    self.error = error
    self.rooms = rooms
  }
}
