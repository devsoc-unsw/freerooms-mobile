//
//  Building.swift
//  Buildings
//
//  Created by Anh Nguyen on 12/1/2025.
//

public struct Building: Equatable {

  // MARK: Lifecycle

  public init(
    name: String,
    id: String,
    latitude: Double,
    longitude: Double,
    aliases: [String])
  {
    self.name = name
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.aliases = aliases
  }

  // MARK: Public

  public let name: String
  public let id: String
  public let latitude: Double
  public let longitude: Double
  public let aliases: [String]
}
