//
//  RoomBooking.swift
//  Rooms
//
//  Created by Chris Wong on 4/9/2025.
//

import Foundation

public struct RoomBooking: Equatable, Sendable, Hashable {

  // MARK: Lifecycle

  public init(bookingType: String, end: Date, name: String, start: Date) {
    self.bookingType = bookingType
    self.end = end
    self.name = name
    self.start = start
  }

  // MARK: Public

  public static let exampleOne = RoomBooking(
    bookingType: "MISC",
    end: Date().addingTimeInterval(60 * 60),
    name: "COMM",
    start: Date())
  public static let exampleTwo = RoomBooking(
    bookingType: "MISC",
    end: Date().addingTimeInterval(-60 * 60 * 4),
    name: "LAW",
    start: Date().addingTimeInterval(-60 * 60 * 5))

  public let bookingType: String
  public let end: Date
  public let name: String
  public let start: Date

}
