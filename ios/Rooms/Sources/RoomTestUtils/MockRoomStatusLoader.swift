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
// swiftlint:disable:next no_unchecked_sendable
public final class MockRoomStatusLoader: RoomStatusLoader {

  // MARK: Lifecycle

  public init(stubbedResponse: RemoteRoomStatus? = nil, stubbedError: RoomStatusLoaderError? = nil) {
    self.stubbedResponse = stubbedResponse
    self.stubbedError = stubbedError
    
  }

  // MARK: Public

  public func fetchRoomStatus() async -> Result<RemoteRoomStatus, RoomStatusLoaderError> {
    if let stubbedError {
      return .failure(stubbedError)
    }

    if let stubbedResponse {
      return .success(stubbedResponse)
    }

    return .failure(.connectivity)
  }

  // MARK: Private
  
  private let stubbedResponse: RemoteRoomStatus?
  private let stubbedError: RoomStatusLoaderError?
}
