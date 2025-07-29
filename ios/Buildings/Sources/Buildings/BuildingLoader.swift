//
//  BuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Networking

// MARK: - BuildingLoaderError

public enum BuildingLoaderError: Error {
  case connectivity
  case noDataAvailable
  case persistenceError
}

// MARK: - BuildingLoader

public protocol BuildingLoader {
  func fetch() async -> Result<[Building], Error>
}

// MARK: - RemoteBuildingLoader

public protocol RemoteBuildingLoader {
  func fetch() async -> Result<[RemoteBuilding], BuildingLoaderError>
}

// MARK: - LiveBuildingLoader

public class LiveBuildingLoader: BuildingLoader {

  // MARK: Lifecycle

  public init(remoteBuildingLoader: RemoteBuildingLoader) {
    self.remoteBuildingLoader = remoteBuildingLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Building], Error>

  public func fetch() async -> Result {
    switch await remoteBuildingLoader.fetch() {
    case .success(let remoteBuildings):
      let buildings = remoteBuildings.map {
        Building(name: $0.name, id: $0.id, latitude: $0.latitude, longitude: $0.longitude, aliases: $0.aliases)
      }
      return .success(buildings)

    case .failure:
      return .failure(BuildingLoaderError.connectivity)
    }
  }

  // MARK: Private

  private let remoteBuildingLoader: RemoteBuildingLoader

}
