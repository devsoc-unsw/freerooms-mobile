//
//  MockSwiftDataBuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 13/8/2025.
//

import RoomModels
import RoomServices

public struct MockSwiftDataRoomLoader: SwiftDataRoomLoader {

  // MARK: Lifecycle

  public init(
    loads rooms: [Room] = [],
    onFetchThrows fetchError: RoomLoaderError? = nil,
    onSeedThrows seedError: RoomLoaderError? = nil)
  {
    self.fetchError = fetchError
    self.seedError = seedError
    self.rooms = rooms
  }

  // MARK: Public

  public func fetch() -> Result<[Room], RoomLoaderError> {
    if fetchError != nil {
      return .failure(fetchError!)
    }

    return .success(rooms)
  }

  public func seed(_: [Room]) -> Result<Void, RoomLoaderError> {
    if seedError != nil {
      return .failure(seedError!)
    }

    return .success(())
  }

  // MARK: Internal

  let fetchError: RoomLoaderError?
  let seedError: RoomLoaderError?
  let rooms: [Room]

}
