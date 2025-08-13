//
//  BuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import BuildingModels
import Foundation
import Networking

// MARK: - BuildingLoaderError

public enum BuildingLoaderError: Error {
  /// From Networking
  case connectivity

  /// From SwiftData
  case persistenceError
  case noDataAvailable

  /// From JSONLoader
  case fileNotFound
  case malformedJSON
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

  public init(swiftDataBuildingLoader: SwiftDataBuildingLoader, JSONBuildingLoader: JSONBuildingLoader) {
    self.swiftDataBuildingLoader = swiftDataBuildingLoader
    self.JSONBuildingLoader = JSONBuildingLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Building], BuildingLoaderError>

  public func fetch() async -> Result {
    let hasSavedData = UserDefaults.standard.bool(forKey: "hasSavedData")

    if !hasSavedData {
      switch JSONBuildingLoader.fetch() {
      case .success(let buildings):
        if case .failure(let err) = await swiftDataBuildingLoader.seed(buildings) {
          return .failure(err)
        }
        UserDefaults.standard.set(true, forKey: "hasSavedData")
        return .success(buildings)

      case .failure(let err):
        return .failure(err)
      }
    } else {
      switch await swiftDataBuildingLoader.fetch() {
      case .success(let buildings):
        return .success(buildings)
      case .failure(let err):
        return .failure(err)
      }
    }
  }

  // MARK: Private

  private let swiftDataBuildingLoader: SwiftDataBuildingLoader
  private let JSONBuildingLoader: JSONBuildingLoader

}

// MARK: - LiveRemoteBuildingLoader

public class LiveRemoteBuildingLoader: RemoteBuildingLoader {

  // MARK: Lifecycle

  public init(url: URL) {
    self.url = url
  }

  // MARK: Public

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

  // MARK: Private

  private let url: URL
}
