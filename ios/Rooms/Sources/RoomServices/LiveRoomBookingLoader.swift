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

public struct LiveRoomBookingLoader: RoomBookingLoader {

  // MARK: Lifecycle

  public init(remoteRoomBookingLoader: RemoteRoomBookingLoader) {
    self.remoteRoomBookingLoader = remoteRoomBookingLoader
  }

  // MARK: Public

  public func fetch(bookingsOf roomID: String) async -> Result<[RoomBooking], RoomBookingLoaderError> {
    if roomID.isEmpty {
      return .failure(.invalidBuildingID)
    }
    let dateFormatter = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    switch await remoteRoomBookingLoader.fetch(bookingsOf: roomID) {
    case .success(let remoteRoomBookings):
      return .success(remoteRoomBookings.map {
        RoomBooking(
          bookingType: $0.bookingType,
          end: try! dateFormatter.parse($0.end),
          name: $0.name,
          start: try! dateFormatter.parse($0.start))
      })

    case .failure(let err):
      return .failure(err)
    }
  }

  // MARK: Internal

  let remoteRoomBookingLoader: RemoteRoomBookingLoader
}
