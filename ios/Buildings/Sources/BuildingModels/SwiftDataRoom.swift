//
//  SwiftDataRoom.swift
//  Buildings
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

import Foundation
import Persistence
import RoomModels
import SwiftData

/// A SwiftData model representing a room, linked to a building and used for persistence.
@Model
public final class SwiftDataRoom {

  // MARK: Lifecycle

  /// Initializes a new SwiftDataRoom with all required properties.
  public init(
    abbreviation: String,
    accessibility: [String],
    audioVisual: [String],
    buildingId: String,
    capacity: Int,
    floor: String?,
    id: String,
    infoTechnology: [String],
    latitude: Double,
    longitude: Double,
    microphone: [String],
    name: String,
    school: String,
    seating: String?,
    usage: String,
    service: [String],
    writingMedia: [String],
    building: SwiftDataBuilding)
  {
    self.abbreviation = abbreviation
    self.accessibility = accessibility
    self.audioVisual = audioVisual
    self.buildingId = buildingId
    self.capacity = capacity
    self.floor = floor ?? ""
    self.id = id
    self.infoTechnology = infoTechnology
    self.latitude = latitude
    self.longitude = longitude
    self.microphone = microphone
    self.name = name
    self.school = school
    self.seating = seating ?? ""
    self.usage = usage
    self.service = service
    self.writingMedia = writingMedia
    self.building = building
  }

  /// Initializes SwiftDataRoom from a domain `Room` and related `SwiftDataBuilding`.
  public convenience init(from room: Room, building: SwiftDataBuilding) {
    self.init(
      abbreviation: room.abbreviation,
      accessibility: room.accessibility,
      audioVisual: room.audioVisual,
      buildingId: room.buildingId,
      capacity: room.capacity,
      floor: room.floor ?? "",
      id: room.id,
      infoTechnology: room.infoTechnology,
      latitude: room.latitude,
      longitude: room.longitude,
      microphone: room.microphone,
      name: room.name,
      school: room.school,
      seating: room.seating ?? "",
      usage: room.usage,
      service: room.service,
      writingMedia: room.writingMedia,
      building: building)
  }

  // MARK: Public

  public var abbreviation: String
  public var accessibility: [String]
  public var audioVisual: [String]
  public var buildingId: String
  public var capacity: Int
  public var floor: String?
  public var id: String
  public var infoTechnology: [String]
  public var latitude: Double
  public var longitude: Double
  public var microphone: [String]
  public var name: String
  public var school: String
  public var seating: String?
  public var usage: String
  public var service: [String]
  public var writingMedia: [String]
  @Relationship public var building: SwiftDataBuilding

  /// Converts the persistence model back to the domain `Room` type.
  public func toRoom() -> Room {
    Room(
      abbreviation: abbreviation,
      accessibility: accessibility,
      audioVisual: audioVisual,
      buildingId: buildingId,
      capacity: capacity,
      floor: floor ?? "",
      id: id,
      infoTechnology: infoTechnology,
      latitude: latitude,
      longitude: longitude,
      microphone: microphone,
      name: name,
      school: school,
      seating: seating ?? "",
      usage: usage,
      service: service,
      writingMedia: writingMedia)
  }
}
