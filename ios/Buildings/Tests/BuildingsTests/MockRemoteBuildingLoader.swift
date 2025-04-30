//
//  MockRemoteBuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 30/4/2025.
//

import Buildings

public class MockRemoteBuildingLoader: RemoteBuildingLoader {

  // MARK: Lifecycle

  init(loads remoteBuildings: [RemoteBuilding] = [], throws error: Swift.Error? = nil) {
    self.remoteBuildings = remoteBuildings
    self.error = error
  }

  // MARK: Public

  public func fetch() async -> Result<[RemoteBuilding], Swift.Error> {
    if let error {
      return .failure(error)
    }

    return .success(remoteBuildings)
  }

  // MARK: Private

  private let remoteBuildings: [RemoteBuilding]
  private let error: Swift.Error?

}
