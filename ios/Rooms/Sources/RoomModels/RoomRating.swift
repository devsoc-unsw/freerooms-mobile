//
//  RoomRating.swift
//  Rooms
//
//  Created by Dicko Evaldo on 17/3/2026.
//

// MARK: - RoomRating

//
// URL: https://freerooms.devsoc.app/api/rating/$roomID

public struct RoomRating: Codable, Equatable, Sendable, Hashable {
  public init(roomId: String, overallRating: Double, averageRating: AverageRating) {
    self.roomId = roomId
    self.overallRating = overallRating
    self.averageRating = averageRating
  }

  public let roomId: String
  public let overallRating: Double
  public let averageRating: AverageRating
}

// MARK: - AverageRating

/// represent the rating details on
/// 1. cleanliness
/// 2. location
/// 3. quietness
public struct AverageRating: Codable, Equatable, Sendable, Hashable {
  public init(cleanliness: Double, location: Double, quietness: Double) {
    self.cleanliness = cleanliness
    self.location = location
    self.quietness = quietness
  }

  public let cleanliness: Double
  public let location: Double
  public let quietness: Double
}
