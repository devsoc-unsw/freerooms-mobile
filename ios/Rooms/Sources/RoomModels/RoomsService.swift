//
//  RoomsService.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 5/8/2025.
//

import Foundation

public typealias GetRoomResult = Swift.Result<[Room], FetchRoomError>

// MARK: - FetchRoomError

public enum FetchRoomError: Error, Equatable {
  case connectivity
  case invalidBuildingId
}

// MARK: - RoomService

public protocol RoomService {
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

  // MARK: Private

  private var roomLoader: any RoomLoader
}

// MARK: - RoomLoader

public protocol RoomLoader {
  func fetch(buildingId: String) async -> Result<[Room], RoomLoaderError>
}

// MARK: - PreviewRoomService

public final class PreviewRoomService: RoomService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getRooms(buildingId: String) async -> GetRoomResult {
    // Return mock data for previews
    let mockRooms = [
      Room(name: "Ainsworth G03", id: "\(buildingId)-G03", abbreviation: "Mock G03", capacity: 350, usage: "LEC", school: "UNSW"),
      Room(name: "Ainsworth G04", id: "\(buildingId)-G04", abbreviation: "Mock G04", capacity: 200, usage: "TUT", school: "UNSW"),
      Room(name: "Ainsworth 201", id: "\(buildingId)-201", abbreviation: "Mock 201", capacity: 50, usage: "LAB", school: "CSE"),
    ]

    return .success(mockRooms)
  }
}

// MARK: - RoomLoaderError

public enum RoomLoaderError: Error {
  case connectivity
  case noDataAvailable
}
