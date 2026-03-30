//
//  RoomRatingLoader.swift
//  Rooms
//
//  Created by Dicko Evaldo on 17/3/2026.
//
import Foundation
import Networking
import RoomModels
import VISOR

// MARK: - RoomRatingLoaderError

public enum RoomRatingLoaderError: Error, Equatable {
  case connectivity
  case invalidRoomID
  case invalidURL
}

// MARK: - RoomRatingLoader

@Stubbable
public protocol RoomRatingLoader {
  func fetchRoomRating(roomID: String) async -> Result<RoomRating, RoomRatingLoaderError>
}

extension RoomRatingLoaderError {
  public var clientMessage: String {
    switch self {
    case .connectivity:
      "Failed to fetch room rating. Please check your internet connection."
    case .invalidRoomID:
      "Invalid room ID provided."
    case .invalidURL:
      "API URL doesn't exist."
    }
  }
}

// MARK: - LiveRoomRatingLoader

public struct LiveRoomRatingLoader: RoomRatingLoader {

  // MARK: Lifecycle

  public init(client: HTTPClient, baseURL: URL, statusEndpointPath: String = "/api/rating/") {
    self.client = client
    self.baseURL = baseURL
    self.statusEndpointPath = statusEndpointPath
  }

  // MARK: Public

  public func fetchRoomRating(roomID: String) async -> Result<RoomRating, RoomRatingLoaderError> {
    guard !roomID.isEmpty else {
      return .failure(.invalidRoomID)
    }

    guard let url = URL(string: statusEndpointPath + roomID, relativeTo: baseURL) else {
      return .failure(.invalidURL)
    }

    let loader = NetworkCodableLoader<RoomRating>(client: client, url: url)

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
