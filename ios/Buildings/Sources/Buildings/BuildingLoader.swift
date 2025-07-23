//
//  BuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Foundation
import Networking

// MARK: - BuildingLoaderError

public enum BuildingLoaderError: Error {
  case connectivity
  case noDataAvailable
  case persistenceError
}

// MARK: - BuildingLoader

public protocol BuildingLoader {
  func fetch() async -> Result<[Building], BuildingLoaderError>
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

  public typealias Result = Swift.Result<[Building], BuildingLoaderError>

  public func fetch() async -> Result {
    switch await remoteBuildingLoader.fetch() {
    case .success(let remoteBuildings):
      let buildings = remoteBuildings.map {
        Building(name: $0.name, id: $0.id, latitude: $0.latitude, longitude: $0.longitude, aliases: $0.aliases)
      }
      return .success(buildings)

    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private let remoteBuildingLoader: RemoteBuildingLoader

}

// MARK: - LiveRemoteBuildingLoader

public class LiveRemoteBuildingLoader: RemoteBuildingLoader {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func fetch() async -> Result<[RemoteBuilding], BuildingLoaderError> {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(.connectivity)
            }
            let buildings = try JSONDecoder().decode([RemoteBuilding].self, from: data)
            return .success(buildings)
        } catch {
            return .failure(.connectivity)
        }
    }
}
