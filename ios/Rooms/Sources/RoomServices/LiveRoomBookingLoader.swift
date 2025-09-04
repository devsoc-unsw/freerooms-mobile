//
//  LiveRoomBookingLoader.swift
//  Rooms
//
//  Created by Chris Wong on 4/9/2025.
//

import Foundation
import RoomModels

// MARK: - RoomBookingLoaderError

public enum RoomBookingLoaderError: Error {
  case connectivity, invalidBuildingID, invalidURL
}

// MARK: - RoomBookingLoader

public protocol RoomBookingLoader {
  func fetch(bookingsOf roomID: String) async -> Result<[RoomBooking], RoomBookingLoaderError>
}

// MARK: - LiveRoomBookingLoader

public struct LiveRoomBookingLoader {

  // MARK: Lifecycle

  public init(remoteRoomBookingLoader: RemoteRoomBookingLoader) {
    self.remoteRoomBookingLoader = remoteRoomBookingLoader
  }

  // MARK: Public

  public func fetch(bookingsOf roomID: String) async -> Result<[RoomBooking], RoomBookingLoaderError> {
    if roomID.isEmpty {
      return .failure(.invalidBuildingID)
    }
    switch await remoteRoomBookingLoader.fetch(bookingsOf: roomID) {
    case .success(let remoteRoomBookings):
      return .success(remoteRoomBookings.map {
        RoomBooking(
          bookingType: $0.bookingType,
          end: ISO8601DateFormatter().date(from: $0.end) ?? nil,
          name: $0.name,
          start: ISO8601DateFormatter().date(from: $0.start) ?? nil)
      })

    case .failure(let err):
      return .failure(err)
    }
  }

  // MARK: Internal

  let remoteRoomBookingLoader: RemoteRoomBookingLoader
}
