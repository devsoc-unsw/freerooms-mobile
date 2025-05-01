//
//  BuildingModel.swift
//  DB
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

import Buildings
import Foundation
import SwiftData

/// A SwiftData model representing a building, including location and associated rooms.
@Model
public final class BuildingModel: PersistentModel {

  // MARK: Lifecycle

  /// Initializes a new BuildingModel with all required properties.
  public init(
    name: String,
    id: String,
    latitude: Double,
    longitude: Double,
    aliases: [String],
    numberOfAvailableRooms: Int?,
    rooms: [RoomModel] = [])
  {
    self.name = name
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.aliases = aliases
    self.numberOfAvailableRooms = numberOfAvailableRooms
    self.rooms = rooms
  }

  /// Initializes BuildingModel from a domain `Building`.
  public convenience init(from building: Building) {
    self.init(
      name: building.name,
      id: building.id,
      latitude: building.latitude,
      longitude: building.longitude,
      aliases: building.aliases,
      numberOfAvailableRooms: building.numberOfAvailableRooms)
  }

  // MARK: Public

  public var name: String
  public var id: String
  public var latitude: Double
  public var longitude: Double
  public var aliases: [String]
  public var numberOfAvailableRooms: Int?

  /// Associated rooms; cascade delete ensures related rooms are deleted with the building.
  @Relationship(deleteRule: .cascade)
  public var rooms: [RoomModel]

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
