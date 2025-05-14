//
//  RemoteBuilding.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Foundation

public struct RemoteBuilding: Equatable, Codable {
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
