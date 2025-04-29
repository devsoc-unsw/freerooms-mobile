//
//  Building.swift
//  Buildings
//
//  Created by Anh Nguyen on 12/1/2025.
//

public struct Building: Equatable {
  public let name: String
  public let id: String
  public let latitude: Double
  public let longitude: Double
  public let aliases: [String]
  public let numberOfAvailableRooms: Int?

  public init(name: String, id: String, latitude: Double, longitude: Double, aliases: [String], numberOfAvailableRooms: Int?) {
    self.name = name
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.aliases = aliases
    self.numberOfAvailableRooms = numberOfAvailableRooms
  }
}
