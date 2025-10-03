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

@MainActor
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

  public func getBuildings() -> GetBuildingsResult {
    .success([
      Building(name: "AGSM", id: "K-E4", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
      Building(name: "Biological Sciences", id: "K-E8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 2),
      Building(
        name: "Biological Sciences (West)",
        id: "K-E10",
        latitude: 0,
        longitude: 0,
        aliases: [],
        numberOfAvailableRooms: 3),
      Building(name: "Matthews Building", id: "K-E12", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 4),
      Building(
        name: "Morven Brown Building",
        id: "K-C20",
        latitude: -33.916792,
        longitude: 151.232828,
        aliases: [],
        numberOfAvailableRooms: nil),
      Building(
        name: "Wallace Wurth Building",
        id: "K-B16",
        latitude: -33.916744,
        longitude: 151.235681,
        aliases: [],
        numberOfAvailableRooms: nil),
    ])
  }
}
