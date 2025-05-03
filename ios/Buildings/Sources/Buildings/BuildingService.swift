//
//  BuildingService.swift
//  Buildings
//
//  Created by Anh Nguyen on 22/4/2025.
//

import Foundation
import Networking

// MARK: - BuildingService

public final class BuildingService {

  // MARK: Lifecycle

  init(buildingLoader: any BuildingLoader) {
    self.buildingLoader = buildingLoader
  }

  // MARK: Public

  public enum FetchBuildingsError: Error {
    case getBuildingsConnectivity
  }

  public typealias GetBuildingsResult = Swift.Result<[Building], FetchBuildingsError>

  public func getBuildings() async -> GetBuildingsResult {
    switch await buildingLoader.fetch() {
    case .success(let buildings):
      .success(buildings)
    case .failure:
      .failure(.getBuildingsConnectivity)
    }
  }

  // MARK: Private

  private var buildingLoader: any BuildingLoader
}
