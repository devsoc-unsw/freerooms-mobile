//
//  BuildingService.swift
//  Buildings
//
//  Created by Anh Nguyen on 22/4/2025.
//

import Foundation
import Networking

// MARK: - BuildingService

public enum BuildingServiceError: Error {
  case connectivity
}

public final class BuildingService {

  // MARK: Lifecycle

  init(buildingLoader: any BuildingLoader) {
    self.buildingLoader = buildingLoader
  }
  
  public enum Error: Swift.Error {
    case connectivity
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Building], BuildingServiceError>

  // MARK: Internal

  func getBuildings() async -> Result {
    switch await buildingLoader.fetch() {
    case .success(let buildings):
      .success(buildings)
    case .failure(_):
      .failure(.connectivity)
    }
  }

  // MARK: Private

  private var buildingLoader: any BuildingLoader
}
