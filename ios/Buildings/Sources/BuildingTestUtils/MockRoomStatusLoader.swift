//
//  MockRoomStatusLoader.swift
//  BuildingTestUtils
//
//  Created by Muqueet Mohsen Chowdhury on 2/9/2025.
//

import BuildingModels
import BuildingServices
import Foundation

// MARK: - MockRoomStatusLoader

public final class MockRoomStatusLoader: RoomStatusLoader {

  // MARK: Lifecycle

  public init() { }

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

  public func stubSuccess(_ response: RemoteRoomStatus) {
    stubbedResponse = response
    stubbedError = nil
  }

  public func stubFailure(_ error: RoomStatusLoaderError = .connectivity) {
    stubbedError = error
    stubbedResponse = nil
  }

  // MARK: Private

  private var stubbedResponse: RemoteRoomStatus?
  private var stubbedError: RoomStatusLoaderError?
}
