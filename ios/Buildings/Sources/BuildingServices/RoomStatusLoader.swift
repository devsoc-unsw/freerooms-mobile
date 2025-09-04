//
//  RoomStatusLoader.swift
//  Buildings
//
//  Created by Muqueet Mohsen Chowdhury on 2/9/2025.
//

import BuildingModels
import Foundation
import Networking

// MARK: - RoomStatusLoaderError

public enum RoomStatusLoaderError: Error, Equatable {
  case connectivity
  case invalidData
}

// MARK: - RoomStatusLoader

public protocol RoomStatusLoader {
  func fetchRoomStatus() async -> Result<RemoteRoomStatus, RoomStatusLoaderError>
}

// MARK: - LiveRoomStatusLoader

public final class LiveRoomStatusLoader: RoomStatusLoader {

  // MARK: Lifecycle

  public init(client: HTTPClient, baseURL: URL, statusEndpointPath: String = "/api/rooms/status") {
    self.client = client
    self.baseURL = baseURL
    self.statusEndpointPath = statusEndpointPath
  }

  // MARK: Public

  public func fetchRoomStatus() async -> Result<RemoteRoomStatus, RoomStatusLoaderError> {
    guard let url = URL(string: statusEndpointPath, relativeTo: baseURL) else {
      return .failure(.invalidData)
    }

    let loader = NetworkCodableLoader<RemoteRoomStatus>(client: client, url: url)

    switch await loader.fetch() {
    case .success(let response):
      return .success(response)
    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private let client: HTTPClient
  private let baseURL: URL
  private let statusEndpointPath: String
}
