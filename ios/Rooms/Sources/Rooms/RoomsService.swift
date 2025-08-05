//
//  RoomsService.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 5/8/2025.
//

import Foundation

public typealias GetRoomsResult = Swift.Result<[Room], FetchRoomsError>

// MARK: - FetchRoomsError

public enum FetchRoomsError: Error, Equatable {
  case connectivity
  case invalidBuildingId
}

// MARK: - RoomsService

public protocol RoomsService {
  func getRooms(buildingId: String) async -> GetRoomsResult
}

// MARK: - LiveRoomsService

public final class LiveRoomsService: RoomsService {

  // MARK: Lifecycle

  public init(roomsLoader: any RoomsLoader) {
    self.roomsLoader = roomsLoader
  }

  // MARK: Public

  public typealias GetRoomsResult = Swift.Result<[Room], FetchRoomsError>

  public func getRooms(buildingId: String) async -> GetRoomsResult {
    // Validate input
    guard !buildingId.isEmpty else {
      return .failure(.invalidBuildingId)
    }

    switch await roomsLoader.fetch(buildingId: buildingId) {
    case .success(let rooms):
      return .success(rooms)
    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private var roomsLoader: any RoomsLoader
}

// MARK: - RoomsLoader

public protocol RoomsLoader {
  func fetch(buildingId: String) async -> Result<[Room], RoomsLoaderError>
}

// MARK: - PreviewRoomsService

public final class PreviewRoomsService: RoomsService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getRooms(buildingId: String) async -> GetRoomsResult {
    // Return mock data for previews
    let mockRooms = [
      Room(name: "Ainsworth G03", id: "\(buildingId)-G03", abbreviation: "Mock G03", capacity: 350, usage: "LEC", school: "UNSW"),
      Room(name: "Ainsworth G04", id: "\(buildingId)-G04", abbreviation: "Mock G04", capacity: 200, usage: "TUT", school: "UNSW"),
      Room(name: "Ainsworth 201", id: "\(buildingId)-201", abbreviation: "Mock 201", capacity: 50, usage: "LAB", school: "CSE"),
    ]

    return .success(mockRooms)
  }
}

// MARK: - RoomsLoaderError

public enum RoomsLoaderError: Error {
  case connectivity
  case noDataAvailable
}
