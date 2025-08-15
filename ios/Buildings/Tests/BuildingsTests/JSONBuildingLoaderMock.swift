//
//  JSONBuildingLoaderMock.swift
//  Buildings
//
//  Created by Chris Wong on 13/8/2025.
//

import BuildingModels
import BuildingServices

struct JSONBuildingLoaderMock: JSONBuildingLoader {

  // MARK: Lifecycle

  init(loads buildings: [Building] = [], throws error: BuildingLoaderError? = nil) {
    self.buildings = buildings
    self.error = error
  }

  // MARK: Internal

  let buildings: [Building]
  let error: BuildingLoaderError?

  func decode(from _: String) -> Result<[Building], BuildingLoaderError> {
    if error != nil {
      return .failure(error!)
    }

    return .success(buildings)
  }

  func fetch() -> Result<[Building], BuildingLoaderError> {
    if error != nil {
      return .failure(error!)
    }

    return .success(buildings)
  }

}
