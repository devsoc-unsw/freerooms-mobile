//
//  MockRemoteBuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Buildings

public class MockBuildingLoader: BuildingLoader {

  // MARK: Lifecycle

  init(loads buildings: [Building] = [], throws error: Swift.Error? = nil) {
    self.buildings = buildings
    self.error = error
  }

  // MARK: Public

  public func fetch() async -> Result<[Building], Swift.Error> {
    if let error {
      return .failure(error)
    }

    return .success(buildings)
  }

  // MARK: Private

  private let buildings: [Building]
  private let error: Swift.Error?

}
