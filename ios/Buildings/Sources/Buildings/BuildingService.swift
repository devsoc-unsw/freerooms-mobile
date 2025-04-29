//
//  BuildingService.swift
//  Buildings
//
//  Created by Anh Nguyen on 22/4/2025.
//

import Foundation
import Networking

// MARK: - BuildingService

class BuildingService {

  // MARK: Lifecycle

  init(buildingLoader: any BuildingLoader) {
    self.buildingLoader = buildingLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[RemoteBuilding], Swift.Error>

  // MARK: Internal

  func getBuildings() async -> Result {
    switch await buildingLoader.fetch() {
    case .success(let buildings):
      .success(buildings)
    case .failure(let error):
      .failure(error)
    }
  }

  // MARK: Private

  private var buildingLoader: any BuildingLoader
}
