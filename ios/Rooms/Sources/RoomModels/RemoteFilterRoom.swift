//
//  RemoteFilterRoom.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/4/2026.
//

import Foundation

public typealias RemoteFilterRoomMap = [String: RemoteFilterRoomValue]

// MARK: - RemoteFilterRoomValue

/// Represents the details of a room returned from the remote API when fetching filtered rooms.
public struct RemoteFilterRoomValue: Codable, Equatable, Sendable {
  public let status: String
  public let endTime: String
  public let name: String

  enum CodingKeys: String, CodingKey {
    case status
    case endTime = "endtime"
    case name
  }
}
