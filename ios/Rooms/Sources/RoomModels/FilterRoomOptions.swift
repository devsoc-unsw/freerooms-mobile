//
//  FilterRoomOptions.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/4/2026.
//

import Foundation

public struct FilterRoomOptions: Equatable, Sendable {

  // MARK: Lifecycle

  public init(
    dateTime: String? = nil,
    startTime: String? = nil,
    endTime: String? = nil,
    buildingId: String? = nil,
    capacity: Int? = nil,
    duration: Int? = nil,
    usage: String? = nil,
    location: String? = nil,
    sortedBySpecificSchoolId: Bool = false)
  {
    self.dateTime = dateTime
    self.startTime = startTime
    self.endTime = endTime
    self.buildingId = buildingId
    self.capacity = capacity
    self.duration = duration
    self.usage = usage
    self.location = location
    self.sortedBySpecificSchoolId = sortedBySpecificSchoolId
  }

  // MARK: Public

  public let dateTime: String?
  public let startTime: String?
  public let endTime: String?
  public let buildingId: String?
  public let capacity: Int?
  public let duration: Int?
  public let usage: String?
  public let location: String?
  public let sortedBySpecificSchoolId: Bool

}
