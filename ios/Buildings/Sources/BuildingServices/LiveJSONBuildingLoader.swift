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

@MainActor
public protocol JSONBuildingLoader {
  func fetch() -> Swift.Result<[Building], BuildingLoaderError>
}

// MARK: - LiveJSONBuildingLoader

public struct LiveJSONBuildingLoader: JSONBuildingLoader {

  // MARK: Lifecycle

  public init(using loader: any JSONLoader<[DecodableBuilding]>) {
    self.loader = loader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Building], BuildingLoaderError>

  public var buildingsSeedJSONPath: String? {
    Bundle.module.path(forResource: "BuildingsSeed", ofType: "json")
  }

  public func fetch() -> Result {
    guard let buildingsSeedJSONPath else {
      fatalError("No JSON Buildings Seed bundled")
    }

    switch loader.load(from: buildingsSeedJSONPath) {
    case .success(let JSONBuildingsResponse):
      let buildings = JSONBuildingsResponse.map {
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

  private let loader: any JSONLoader<[DecodableBuilding]>

}
