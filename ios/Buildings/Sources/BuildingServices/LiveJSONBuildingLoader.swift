//
//  LiveJSONBuildingLoader.swift
//  Persistence
//
//  Created by Chris Wong on 30/6/2025.
//

import BuildingModels
import Foundation
import Persistence

// MARK: - JSONBuildingLoader

public protocol JSONBuildingLoader {
  func decode(from filename: String) -> Swift.Result<[Building], BuildingLoaderError>
  func fetch() -> Swift.Result<[Building], BuildingLoaderError>
}

// MARK: - LiveJSONBuildingLoader

public struct LiveJSONBuildingLoader: JSONBuildingLoader {

  // MARK: Lifecycle

  public init(using loader: any JSONLoader<DecodableBuildingData>) {
    self.loader = loader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Building], BuildingLoaderError>

  public var buildingsSeedJSONPath: String? {
    Bundle.module.path(forResource: "BuildingsSeed", ofType: "json")
  }

  public func decode(from filename: String) -> Result {
    switch loader.load(from: filename) {
    case .success(let decodedBuildings):
      let buildings = decodedBuildings.data.buildings.map {
        Building(name: $0.name, id: $0.id, latitude: $0.lat, longitude: $0.long, aliases: $0.aliases)
      }
      return .success(buildings)

    case .failure(.fileNotFound):
      return .failure(.fileNotFound)

    case .failure(.malformedJSON):
      return .failure(.malformedJSON)
    }
  }

  public func fetch() -> Result {
    guard let buildingsSeedJSONPath else {
      fatalError("No JSON Buildings Seed bundled")
    }

    switch loader.load(from: buildingsSeedJSONPath) {
    case .success(let JSONBuildingsResponse):
      let buildings = JSONBuildingsResponse.data.buildings.map {
        Building(name: $0.name, id: $0.id, latitude: $0.lat, longitude: $0.long, aliases: $0.aliases)
      }
      return .success(buildings)

    case .failure(.fileNotFound):
      return .failure(.fileNotFound)

    case .failure(.malformedJSON):
      return .failure(.malformedJSON)
    }
  }

  // MARK: Private

  private let loader: any JSONLoader<DecodableBuildingData>

}
