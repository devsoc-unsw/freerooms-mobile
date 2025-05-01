//
//  MockRemoteBuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 30/4/2025.
//

import Buildings

public class MockRemoteBuildingLoader: RemoteBuildingLoader {

  // MARK: Lifecycle

  init(loads remoteBuildings: [RemoteBuilding] = [], throws buildingLoaderError: BuildingLoaderError? = nil) {
    self.remoteBuildings = remoteBuildings
    self.buildingLoaderError = buildingLoaderError
  }

  // MARK: Public

  public func fetch() async -> Result<[RemoteBuilding], BuildingLoaderError> {
    if buildingLoaderError != nil {
      return .failure(.connectivity)
    }

    return .success(remoteBuildings)
  }

  // MARK: Private

  private let remoteBuildings: [RemoteBuilding]
  private let buildingLoaderError: BuildingLoaderError?

}
