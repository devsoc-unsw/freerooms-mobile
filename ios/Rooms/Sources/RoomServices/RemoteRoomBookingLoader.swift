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

  public init(client: HTTPClient, baseURL: URL, statusEndpointPath: String = "/api/rooms/bookings/") {
    self.client = client
    self.baseURL = baseURL
    self.statusEndpointPath = statusEndpointPath
  }

  // MARK: Public

  public func fetch(bookingsOf roomID: String) async -> Result<[RemoteRoomBooking], RoomBookingLoaderError> {
    guard let url = URL(string: statusEndpointPath + roomID, relativeTo: baseURL) else {
      return .failure(.invalidURL)
    }
    let loader = NetworkCodableLoader<RemoteRoomBookingResponse>(client: client, url: url)

    if roomID.isEmpty {
      return .failure(.invalidBuildingID)
    }

    switch await loader.fetch() {
    case .success(let remoteRoomsResponse):
      return .success(remoteRoomsResponse.bookings)

    case .failure(NetworkCodableLoader<[RemoteRoomBooking]>.Error.connectivity):
      return .failure(.connectivity)

    case .failure(NetworkCodableLoader<[RemoteRoomBooking]>.Error.invalidData):
      return .failure(.invalidBuildingID)

    case .failure:
      return .failure(.connectivity)
    }
  }
  
  

  // MARK: Private

  private let client: HTTPClient
  private let baseURL: URL
  private let statusEndpointPath: String
}
