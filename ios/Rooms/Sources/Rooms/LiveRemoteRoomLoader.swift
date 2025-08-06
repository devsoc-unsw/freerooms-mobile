//
//  LiveRemoteRoomLoader.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

import Foundation
import Networking

// MARK: - RemoteRoomLoader

public protocol RemoteRoomLoader {
  func fetch(buildingId: String) async -> Result<[RemoteRoom], RemoteRoomLoaderError>
}

// MARK: - LiveRemoteRoomLoader

public final class LiveRemoteRoomLoader: RemoteRoomLoader {

  // MARK: Lifecycle

  public init(client: HTTPClient, baseURL: URL) {
    self.client = client
    self.baseURL = baseURL
  }

  // MARK: Public

  public func fetch(buildingId: String) async -> Result<[RemoteRoom], RemoteRoomLoaderError> {
    let url = baseURL.appendingPathComponent("buildings").appendingPathComponent(buildingId).appendingPathComponent("rooms")

    let loader = NetworkCodableLoader<[RemoteRoom]>(client: client, url: url)

    switch await loader.fetch() {
    case .success(let remoteRooms):
      return .success(remoteRooms)
    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private let client: HTTPClient
  private let baseURL: URL
}

// MARK: - RemoteRoomLoaderError

public enum RemoteRoomLoaderError: Error {
  case connectivity
  case invalidData
}
