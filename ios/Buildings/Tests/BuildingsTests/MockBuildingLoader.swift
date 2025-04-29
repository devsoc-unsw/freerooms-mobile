//
//  MockBuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Buildings

public class MockBuildingLoader: BuildingLoader {
  private let buildings: [Building]
  private let error: Swift.Error?

  init(loads Buildings: [Building] = [], error: Swift.Error? = nil) {
    self.buildings = Buildings
    self.error = error
  }

  public func fetch() async -> Result<[Building], Swift.Error> {
    if let error {
      return .failure(error)
    }
    
    return .success(buildings)
  }
}
