//
//  RoomBooking.swift
//  Rooms
//
//  Created by Chris Wong on 4/9/2025.
//

import Foundation

public struct RoomBooking: Equatable {
  public let bookingType: String
  public let end: Date?
  public let name: String
  public let start: Date?

  public init(bookingType: String, end: Date?, name: String, start: Date?) {
    self.bookingType = bookingType
    self.end = end
    self.name = name
    self.start = start
  }
}
