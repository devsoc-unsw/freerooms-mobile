//
//  SwiftDataRoom.swift
//  Buildings
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

import Foundation
import Persistence
import Rooms
import SwiftData

/// A SwiftData model representing a room, linked to a building and used for persistence.
@Model
public final class SwiftDataRoom {

  // MARK: Lifecycle

  /// Initializes a new SwiftDataRoom with all required properties.
  public init(
    name: String,
    id: String,
    building: SwiftDataBuilding,
    abbreviation: String,
    capacity: Int,
    usage: String,
    school: String)
  {
    self.name = name
    self.id = id
    self.building = building
    self.capacity = capacity
    self.abbreviation = abbreviation
    self.capacity = capacity
    self.usage = usage
    self.school = school
  }

  /// Initializes SwiftDataRoom from a domain `Room` and related `SwiftDataBuilding`.
  public convenience init(from room: Room, building: SwiftDataBuilding) {
    self.init(
      name: room.name,
      id: room.id,
      building: building,
      abbreviation: room.abbreviation,
      capacity: room.capacity,
      usage: room.usage,
      school: room.school)
  }

  // MARK: Public

  public var name: String
  public var id: String
  public var abbreviation: String
  public var usage: String
  public var school: String
  @Relationship public var building: SwiftDataBuilding
  public var capacity: Int

  /// Converts the persistence model back to the domain `Room` type.
  public func toRoom() -> Room {
    Room(name: name, id: id, abbreviation: abbreviation, capacity: capacity, usage: usage, school: school)
  }
}
