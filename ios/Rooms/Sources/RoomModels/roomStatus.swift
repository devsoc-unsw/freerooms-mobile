//
//  RemoteRoomStatus.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 2/9/2025.
//

import Foundation

// MARK: - RemoteRoomStatus

/// Response model for the /api/rooms/status endpoint
public typealias RemoteRoomStatus = [String: BuildingRoomStatus]

// MARK: - BuildingRoomStatus

/// Represents room status data for a specific building
public struct BuildingRoomStatus: Codable, Equatable {
  public let numAvailable: Int
  public let roomStatuses: [String: RoomStatus]

  public init(numAvailable: Int, roomStatuses: [String: RoomStatus]) {
    self.numAvailable = numAvailable
    self.roomStatuses = roomStatuses
  }
}

// MARK: - RoomStatus

/// Represents the status of an individual room
public struct RoomStatus: Codable, Equatable {
  public let status: String
  public let endtime: String

  public init(status: String, endtime: String) {
    self.status = status
    self.endtime = endtime
  }
}
