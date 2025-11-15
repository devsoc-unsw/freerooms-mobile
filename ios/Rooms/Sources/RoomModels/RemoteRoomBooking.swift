//
//  RemoteRoomBooking.swift
//  Rooms
//
//  Created by Chris Wong on 4/9/2025.
//

public struct RemoteRoomBooking: Codable {
  public let bookingType: String
  public let end: String
  public let name: String
  public let start: String

  public init(bookingType: String, end: String, name: String, start: String) {
    self.bookingType = bookingType
    self.end = end
    self.name = name
    self.start = start
  }
}
