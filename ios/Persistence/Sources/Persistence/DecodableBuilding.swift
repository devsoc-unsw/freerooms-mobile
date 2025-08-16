//
//  DecodableBuilding.swift
//  Persistence
//
//  Created by Chris Wong on 22/6/2025.
//

// MARK: - DecodableBuildingData

public struct DecodableBuildingData: Decodable {
  public let data: DecodableBuildings

  public init(data: DecodableBuildings) {
    self.data = data
  }
}

// MARK: - DecodableBuildings

public struct DecodableBuildings: Decodable {
  public let buildings: [DecodableBuilding]

  public init(buildings: [DecodableBuilding]) {
    self.buildings = buildings
  }
}

// MARK: - DecodableBuilding

public struct DecodableBuilding: Decodable, Equatable {
  public let name: String
  public let id: String
  public let lat: Double
  public let long: Double
  public let aliases: [String]

  public init(name: String, id: String, lat: Double, long: Double, aliases: [String]) {
    self.name = name
    self.id = id
    self.lat = lat
    self.long = long
    self.aliases = aliases
  }
}
