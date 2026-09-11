//
//  WeeklyBooking.swift
//  Bookings
//
//  Created by Yanlin Li  on 7/8/2025.
//

import Foundation

/// A booking prepared for display in the cross-room weekly discovery feed.
public struct WeeklyBooking: Identifiable, Equatable, Hashable, Sendable {

  // MARK: Lifecycle

  public init(
    title: String,
    bookingType: String?,
    roomID: String,
    roomName: String,
    buildingID: String?,
    buildingName: String?,
    start: Date,
    end: Date,
    usage: String,
    capacity: Int,
    abbreviation: String)
  {
    self.title = title
    self.bookingType = bookingType
    self.roomID = roomID
    self.roomName = roomName
    self.buildingID = buildingID
    self.buildingName = buildingName
    self.start = start
    self.end = end
    self.usage = usage
    self.capacity = capacity
    self.abbreviation = abbreviation
  }

  // MARK: Public

  /// The backend identifies a booking by its room and interval rather than a standalone identifier.
  public struct ID: Equatable, Hashable, Sendable {
    public init(roomID: String, start: Date, end: Date) {
      self.roomID = roomID
      self.start = start
      self.end = end
    }

    public let roomID: String
    public let start: Date
    public let end: Date
  }

  public let title: String
  public let bookingType: String?
  public let roomID: String
  public let roomName: String
  public let buildingID: String?
  public let buildingName: String?
  public let start: Date
  public let end: Date
  public let usage: String
  public let capacity: Int
  public let abbreviation: String

  public var id: ID {
    ID(roomID: roomID, start: start, end: end)
  }
}
