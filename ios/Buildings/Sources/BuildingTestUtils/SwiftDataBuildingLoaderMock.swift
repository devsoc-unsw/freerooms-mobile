//
//  SwiftDataBuildingLoaderMock.swift
//  Buildings
//
//  Created by Chris Wong on 13/8/2025.
//

import BuildingModels
import BuildingServices

public struct SwiftDataBuildingLoaderMock: SwiftDataBuildingLoader {

  // MARK: Lifecycle

  public init(
    loads buildings: [Building] = [],
    onFetchThrows fetchError: BuildingLoaderError? = nil,
    onSeedThrows seedError: BuildingLoaderError? = nil)
  {
    self.fetchError = fetchError
    self.seedError = seedError
    self.buildings = buildings
  }

  // MARK: Public

  public func fetch() -> Result<[Building], BuildingLoaderError> {
    if fetchError != nil {
      return .failure(fetchError!)
    }

    return .success(buildings)
  }

  public func seed(_: [Building]) -> Result<Void, BuildingLoaderError> {
    if seedError != nil {
      return .failure(seedError!)
    }

    return .success(())
  }

  // MARK: Internal

  let fetchError: BuildingLoaderError?
  let seedError: BuildingLoaderError?
  let buildings: [Building]

}
