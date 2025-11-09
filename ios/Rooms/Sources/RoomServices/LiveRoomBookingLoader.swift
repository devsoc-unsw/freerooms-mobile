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
  case connectivity, invalidBuildingID, invalidURL, invalidDateFormat
}

// MARK: - RoomBookingLoader

public protocol RoomBookingLoader {
  func fetch(bookingsOf roomID: String) async -> Result<[RoomBooking], RoomBookingLoaderError>
}

// MARK: - LiveRoomBookingLoader

public struct LiveRoomBookingLoader: RoomBookingLoader {

  // MARK: Lifecycle

  public init(remoteRoomBookingLoader: RemoteRoomBookingLoader) {
    self.remoteRoomBookingLoader = remoteRoomBookingLoader
  }

  // MARK: Public

  public func fetch(bookingsOf roomID: String) async -> Result<[RoomBooking], RoomBookingLoaderError> {
    guard !roomID.isEmpty else {
      return .failure(.invalidBuildingID)
    }

    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    switch await remoteRoomBookingLoader.fetch(bookingsOf: roomID) {
    case .success(let remoteRoomBookings):
      return .success(remoteRoomBookings.map {
        RoomBooking(
          bookingType: $0.bookingType,
          end: formatter.date(from: $0.end)!,
          name: $0.name,
          start: formatter.date(from: $0.start)!)
      })

    case .failure(let err):
      return .failure(err)
    }
  }

  // MARK: Internal

  let remoteRoomBookingLoader: RemoteRoomBookingLoader
}
