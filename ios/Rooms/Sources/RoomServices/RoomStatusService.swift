//
//  RoomStatusService.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 16/8/2025.
//

import Foundation
import Networking

// MARK: - RoomStatusError

public enum RoomStatusError: Error, Equatable {
  case connectivity
  case invalidBuildingId
  case invalidData
}

// MARK: - RoomStatusService

public protocol RoomStatusService {
  func getFreeRoomCount(buildingId: String) async -> Result<Int, RoomStatusError>
}

// MARK: - RemoteRoomStatus

public struct RemoteRoomStatus: Codable, Equatable {
  public let status: String
  public let endtime: String
}

// MARK: - LiveRoomStatusService

public final class LiveRoomStatusService: RoomStatusService {

  // MARK: Lifecycle

  public init(client: HTTPClient, baseURL: URL, statusEndpointPath: String = "/api/rooms/status") {
    self.client = client
    self.baseURL = baseURL
    self.statusEndpointPath = statusEndpointPath
  }

  // MARK: Public

  public func getFreeRoomCount(buildingId: String) async -> Result<Int, RoomStatusError> {
    guard !buildingId.isEmpty else { return .failure(.invalidBuildingId) }

    guard let url = URL(string: statusEndpointPath, relativeTo: baseURL) else {
      return .failure(.invalidData)
    }

    typealias StatusResponse = [String: [String: RemoteRoomStatus]]
    let loader = NetworkCodableLoader<StatusResponse>(client: client, url: url)

    switch await loader.fetch() {
    case .success(let dict):
      let building = dict[buildingId] ?? [:]
      let freeCount = building.values.reduce(into: 0) { count, entry in
        if entry.status.lowercased() == "free" { count += 1 }
      }
      return .success(freeCount)

    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private let client: HTTPClient
  private let baseURL: URL
  private let statusEndpointPath: String
}
