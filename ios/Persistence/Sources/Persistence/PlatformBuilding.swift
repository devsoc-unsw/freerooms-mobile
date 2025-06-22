//
//  PlatformBuilding.swift
//  Persistence
//
//  Created by Chris Wong on 22/6/2025.
//

public struct PlatformBuilding: Decodable, Equatable {
  public let name: String
  public let id: String
  public let latitude: Double
  public let longitude: Double
  public let aliases: [String]

  public init(name: String, id: String, latitude: Double, longitude: Double, aliases: [String]) {
    self.name = name
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.aliases = aliases
  }
}
