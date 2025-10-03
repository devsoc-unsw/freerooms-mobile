//
//  RemoteBuildingRatingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 11/9/2025.
//

import BuildingModels
import Foundation
import Networking

// MARK: - BuildingRatingLoader

public protocol BuildingRatingLoader: Sendable {
  func fetch(buildingID: String) async -> Result<Double, BuildingRatingLoaderError>
}

// MARK: - BuildingRatingLoaderError

public enum BuildingRatingLoaderError: Error {
  case connectivity
  case invalidURL
}

// MARK: - RemoteBuildingRatingLoader

public struct RemoteBuildingRatingLoader: BuildingRatingLoader, Sendable {

  // MARK: Lifecycle

  public init(client: HTTPClient, baseURL: URL, statusEndpointPath: String = "/api/buildingRating/") {
    self.client = client
    self.baseURL = baseURL
    self.statusEndpointPath = statusEndpointPath
  }

  // MARK: Public

  public func fetch(buildingID: String) async -> Result<Double, BuildingRatingLoaderError> {
    guard let url = URL(string: statusEndpointPath + buildingID, relativeTo: baseURL) else {
      return .failure(.invalidURL)
    }

    let loader = NetworkCodableLoader<RemoteBuildingRatingResponse>(client: client, url: url)

    switch await loader.fetch() {
    case .success(let response):
      return .success(response.overallRating)
    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private let client: HTTPClient
  private let baseURL: URL
  private let statusEndpointPath: String
}
