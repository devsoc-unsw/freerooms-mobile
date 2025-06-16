//
//  RoomModel.swift
//  Persistence
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

import Buildings
import Foundation
import SwiftData

/// A SwiftData model representing a room, linked to a building and used for persistence.
@Model
public final class RoomModel: PersistentModel {

  // MARK: Lifecycle

  /// Initializes a new RoomModel with all required properties.
  public init(
    name: String,
    id: String,
    building: BuildingModel,
    type: String,
    capacity: Int,
    floor: Int,
    roomNumber: String,
    buildingCode: String) {
    self.name = name
    self.id = id
    self.building = building
    self.type = type
    self.capacity = capacity
    self.floor = floor
    self.roomNumber = roomNumber
    self.buildingCode = buildingCode
  }

  /// Initializes RoomModel from a domain `Room` and related `BuildingModel`.
  public convenience init(from room: Room, building: BuildingModel) {
    self.init(
      name: room.name,
      id: room.id,
      building: building,
      type: room.type,
      capacity: room.capacity,
      floor: room.floor,
      roomNumber: room.roomNumber,
      buildingCode: room.buildingCode)
  }

  // MARK: Public

  public var name: String
  public var id: String
  @Relationship public var building: BuildingModel
  public var type: String
  public var capacity: Int
  public var floor: Int
  public var roomNumber: String
  public var buildingCode: String

  /// Converts the persistence model back to the domain `Room` type.
  public func toRoom() -> Room {
    Room(
      name: name,
      id: id,
      type: type,
      capacity: capacity,
      floor: floor,
      roomNumber: roomNumber,
      buildingCode: buildingCode)
  }
}
