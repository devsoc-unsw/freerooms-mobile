//
//  RemoteRoomBookingLoader.swift
//  Rooms
//
//  Created by Chris Wong on 4/9/2025.
//

import Foundation
import Networking
import RoomModels

// MARK: - RemoteRoomBookingLoader

public protocol RemoteRoomBookingLoader {
  func fetch(bookingsOf roomID: String) async -> Result<[RemoteRoomBooking], RoomBookingLoaderError>
}

// MARK: - LiveRemoteRoomBookingLoader

public struct LiveRemoteRoomBookingLoader: RemoteRoomBookingLoader {

  // MARK: Lifecycle

  public init(url: URL) {
    self.url = url
  }

  // MARK: Public

  public func fetch(bookingsOf roomID: String) async -> Result<[RemoteRoomBooking], RoomBookingLoaderError> {
    let httpClient = URLSessionHTTPClient(session: URLSession.shared)
    let networkDecodableLoader = NetworkCodableLoader<[RemoteRoomBooking]>(client: httpClient, url: url)

    if roomID.isEmpty {
      return .failure(.invalidBuildingID)
    }

    switch await networkDecodableLoader.fetch() {
    case .success(let remoteRooms):
      return .success(remoteRooms)
    case .failure(NetworkCodableLoader<[RemoteRoomBooking]>.Error.connectivity):
      return .failure(.connectivity)
    case .failure(NetworkCodableLoader<[RemoteRoomBooking]>.Error.invalidData):
      return .failure(.invalidBuildingID)
    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Internal

  let url: URL
}
