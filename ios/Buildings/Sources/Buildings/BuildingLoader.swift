//
//  BuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Networking

public enum BuildingLoaderError: Error {
  case connectivity
}

public protocol BuildingLoader {
  func fetch() async -> Result<[Building], BuildingLoaderError>
}

public protocol RemoteBuildingLoader {
  func fetch() async -> Result<[RemoteBuilding], BuildingLoaderError>
}

public class LiveBuildingLoader: BuildingLoader {
  private let remoteBuildingLoader: RemoteBuildingLoader

  public init(remoteBuildingLoader: RemoteBuildingLoader) {
    self.remoteBuildingLoader = remoteBuildingLoader
  }
  
  public typealias Result = Swift.Result<[Building], BuildingLoaderError>

  public func fetch() async -> Result {
    switch await remoteBuildingLoader.fetch() {
    case .success(let remoteBuildings):
      let buildings = remoteBuildings.map {
        Building(name: $0.name, id: $0.id, latitude: $0.latitude, longitude: $0.longitude, aliases: $0.aliases, numberOfAvailableRooms: $0.numberOfAvailableRooms)
      }
      return .success(buildings)
    case .failure(_):
      return .failure(.connectivity)
    }
  }
  
  
}
