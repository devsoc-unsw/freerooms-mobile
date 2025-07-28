//
//  MockRemoteBuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Buildings

public class MockBuildingLoader: BuildingLoader {

  // MARK: Lifecycle

  init(loads buildings: [Building] = [], throws buildingLoaderError: BuildingLoaderError? = nil) {
    self.buildings = buildings
    self.buildingLoaderError = buildingLoaderError
  }

  // MARK: Public

  public func fetch() async -> Result<[Building], Error> {
    if buildingLoaderError != nil {
      return .failure(buildingLoaderError!)
    }

    return .success(buildings)
  }

  // MARK: Private

  private let buildings: [Building]
  private let buildingLoaderError: BuildingLoaderError?

}
