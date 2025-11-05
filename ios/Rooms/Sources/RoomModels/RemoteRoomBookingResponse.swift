//
//  RemoteRoomBookingResponse.swift
//  Rooms
//
//  Created by Chris Wong on 5/9/2025.
//

nonisolated
public struct RemoteRoomBookingResponse: Codable, Sendable {
  public let id: String
  public let name: String
  public let bookings: [RemoteRoomBooking]

  public init(id: String, name: String, bookings: [RemoteRoomBooking]) {
    self.id = id
    self.name = name
    self.bookings = bookings
  }
}
