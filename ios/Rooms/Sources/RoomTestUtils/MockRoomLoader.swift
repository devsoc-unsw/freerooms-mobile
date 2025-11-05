//
//  MockRoomLoader.swift
//  RoomsTests
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

import Foundation
@testable import RoomModels
@testable import RoomServices

// MARK: - MockRoomLoader

public class MockRoomLoader: RoomLoader {

  // MARK: Public

  public func stubRooms(_ rooms: [Room], for buildingId: String) {
    stubbedRooms[buildingId] = rooms
  }

  public func stubRooms(_ rooms: [Room]) {
    allRooms = rooms
  }

  public func stubError(_ error: RoomLoaderError) {
    stubbedError = error
  }

  public func fetch(buildingId: String) -> Result<[Room], RoomLoaderError> {
    if let error = stubbedError {
      return .failure(error)
    }

    if let rooms = stubbedRooms[buildingId] {
      return .success(rooms)
    }
    return .failure(.noDataAvailable)
  }

  public func fetch() -> Result<[RoomModels.Room], RoomServices.RoomLoaderError> {
    if let error = stubbedError {
      return .failure(error)
    }

    return .success(allRooms)
  }

  // MARK: Private

  private var stubbedRooms = [String: [Room]]()
  private var allRooms = [Room]()
  private var stubbedError: RoomLoaderError?
}
