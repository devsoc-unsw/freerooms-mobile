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
  
  private static let formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  public static let exampleOne = RoomBooking(
      bookingType: "CLASS",
      end: formatter.date(from: "2025-11-11T23:30:00.000Z")!,
      name: "COMM2501 LAB",
      start: formatter.date(from: "2025-11-11T22:00:00.000Z")!)

  public static let exampleTwo = RoomBooking(
      bookingType: "CLASS",
      end: formatter.date(from: "2025-11-12T01:00:00.000Z")!,
      name: "COMM2501 LAB",
      start: formatter.date(from: "2025-11-11T23:30:00.000Z")!)

  public static let exampleThree = RoomBooking(
      bookingType: "CLASS",
      end: formatter.date(from: "2025-11-12T02:30:00.000Z")!,
      name: "COMM2501 LAB",
      start: formatter.date(from: "2025-11-12T01:00:00.000Z")!)

  public static let exampleFour = RoomBooking(
      bookingType: "CLASS",
      end: formatter.date(from: "2025-11-12T04:00:00.000Z")!,
      name: "COMM2501 LAB",
      start: formatter.date(from: "2025-11-12T02:30:00.000Z")!)
  
  
  public let bookingType: String
  public let end: Date
  public let name: String
  public let start: Date

}
