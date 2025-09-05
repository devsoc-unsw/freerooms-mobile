//
//  BuildingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import BuildingModels
import Foundation
import Networking
import Persistence

// MARK: - BuildingLoaderError

public enum BuildingLoaderError: Error {
  case connectivity
  case persistenceError
  case noDataAvailable
  case fileNotFound
  case malformedJSON
}

// MARK: - BuildingLoader

public protocol BuildingLoader {
  func fetch() -> Result<[Building], BuildingLoaderError>
}

// MARK: - RemoteBuildingLoader

public protocol RemoteBuildingLoader {
  func fetch() -> Result<[RemoteBuilding], BuildingLoaderError>
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

  public func fetch() -> Result {
    if !hasSavedData {
      switch JSONBuildingLoader.fetch() {
      case .success(let buildings):
        if case .failure(let err) = swiftDataBuildingLoader.seed(buildings) {
          return .failure(err)
        }
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSavedBuildingsData)
        return .success(buildings)

      case .failure(let err):
        return .failure(err)
      }
    } else {
      switch swiftDataBuildingLoader.fetch() {
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

  private var hasSavedData: Bool {
    UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData)
  }

}
