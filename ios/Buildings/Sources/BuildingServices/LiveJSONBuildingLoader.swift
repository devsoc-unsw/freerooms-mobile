//
//  LiveJSONBuildingLoader.swift
//  Persistence
//
//  Created by Chris Wong on 30/6/2025.
//

import BuildingModels
import Persistence

public struct LiveJSONBuildingLoader: BuildingLoader {

  // MARK: Lifecycle

  public init(using loader: any JSONLoader<[DecodableBuilding]>) {
    self.loader = loader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Building], BuildingLoaderError>

  public func decode(from filename: String) -> Result {
    switch loader.load(from: filename) {
    case .success(let decodedBuildings):
      let buildings = decodedBuildings.map {
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
    switch loader.load(from: "/path") {
    case .success(let decodedBuildings):
      let buildings = decodedBuildings.map {
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
