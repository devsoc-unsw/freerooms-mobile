//
//  MockRoomStatusLoader.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 2/9/2025.
//

import Foundation
import RoomModels
import RoomServices

// MARK: - MockRoomStatusLoader

public struct MockRoomStatusLoader: RoomStatusLoader {

  // MARK: Lifecycle

  public init(stubbedResponse: RemoteRoomStatus? = nil, stubbedError: RoomStatusLoaderError? = nil) {
    self.stubbedResponse = stubbedResponse
    self.stubbedError = stubbedError
  }

  // MARK: Public

  public func fetchRoomStatus() async -> Result<RemoteRoomStatus, RoomStatusLoaderError> {
    if let error {
      return .failure(error)
    }

    if let remoteRoomStatus {
      return .success(remoteRoomStatus)
    }

    return .failure(.connectivity)
  }

  // MARK: Private

  private let stubbedResponse: RemoteRoomStatus?
  private let stubbedError: RoomStatusLoaderError?
}
