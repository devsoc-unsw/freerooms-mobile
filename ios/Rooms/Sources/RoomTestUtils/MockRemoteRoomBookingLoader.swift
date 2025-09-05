//
//  MockRemoteRoomBookingLoader.swift
//  Rooms
//
//  Created by Chris Wong on 4/9/2025.
//

import RoomModels
import RoomServices

struct MockRemoteRoomBookingLoader: RemoteRoomBookingLoader {

  public init(throws error: RoomBookingLoaderError? = nil, loads remoteRoomBookings: [RemoteRoomBooking] = []) {
    self.error = error
    self.remoteRoomBookings = remoteRoomBookings
  }

  func fetch(bookingsOf _: String) async -> Result<[RoomModels.RemoteRoomBooking], RoomServices.RoomBookingLoaderError> {
    if let error {
      return .failure(error)
    }

    return .success(remoteRoomBookings)
  }

  public let error: RoomBookingLoaderError?
  public let remoteRoomBookings: [RemoteRoomBooking]

}
