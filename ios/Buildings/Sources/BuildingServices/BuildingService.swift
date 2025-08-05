//
//  BuildingService.swift
//  Buildings
//
//  Created by Anh Nguyen on 22/4/2025.
//

import BuildingModels
import Foundation
import Networking

public typealias GetBuildingsResult = Swift.Result<[Building], FetchBuildingsError>

// MARK: - FetchBuildingsError

public enum FetchBuildingsError: Error {
  case connectivity
}

// MARK: - BuildingService

public protocol BuildingService {
  func getBuildings() async -> GetBuildingsResult
}

// MARK: - LiveBuildingService

public final class LiveBuildingService: BuildingService {

  // MARK: Lifecycle

  public init(buildingLoader: any BuildingLoader) {
    self.buildingLoader = buildingLoader
  }

  // MARK: Public

  public typealias GetBuildingsResult = Swift.Result<[Building], FetchBuildingsError>

  public func getBuildings() async -> GetBuildingsResult {
    switch await buildingLoader.fetch() {
    case .success(let buildings):
      .success(buildings)
    case .failure:
      .failure(.connectivity)
    }
  }

  // MARK: Private

  private var buildingLoader: any BuildingLoader
}

// MARK: - PreviewBuildingService

public final class PreviewBuildingService: BuildingService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getBuildings() async -> GetBuildingsResult {
    .success([])
  }
}
