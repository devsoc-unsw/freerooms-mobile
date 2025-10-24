//
//  SwiftDataBuilding.swift
//  Buildings
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

import Foundation
import Persistence
import SwiftData

/// A SwiftData model representing a building, including location and associated rooms.
@Model
public final class SwiftDataBuilding: IdentifiableModel {

  // MARK: Lifecycle

  /// Initializes a new SwiftDataBuilding with all required properties.
  public init(
    name: String,
    id: String,
    latitude: Double,
    longitude: Double,
    aliases: [String],
    numberOfAvailableRooms: Int?)
  {
    self.name = name
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.aliases = aliases
    self.numberOfAvailableRooms = numberOfAvailableRooms
  }

  // MARK: Public

  public var name: String
  public var id: String
  public var latitude: Double
  public var longitude: Double
  public var aliases: [String]
  public var numberOfAvailableRooms: Int?

  // MARK: - IdentifiableModel

  public var stringID: String {
    id
  }

  /// Converts the persistence model back to a domain `Building`.
  public func toBuilding() -> Building {
    Building(
      name: name,
      id: id,
      latitude: latitude,
      longitude: longitude,
      aliases: aliases,
      numberOfAvailableRooms: numberOfAvailableRooms)
  }
}
