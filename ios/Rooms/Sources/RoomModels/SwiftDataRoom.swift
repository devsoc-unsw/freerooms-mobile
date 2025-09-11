//
//  SwiftDataRoom.swift
//  Buildings
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 2/5/25.
//

import Foundation
import Persistence
import SwiftData

/// A SwiftData model representing a room, linked to a building and used for persistence.
/// Stores detailed room information including facilities, capacity, and location.
@Model
public final class SwiftDataRoom: IdentifiableModel {

  // MARK: Lifecycle

  /// Initializes a new SwiftDataRoom with all required properties.
  /// - Parameters:
  ///   - abbreviation: Short code for the room
  ///   - accessibility: Accessibility features available
  ///   - audioVisual: Audio-visual equipment available
  ///   - buildingId: ID of the building containing this room
  ///   - capacity: Maximum number of people the room can accommodate
  ///   - floor: Floor level where the room is located
  ///   - id: Unique identifier for the room
  ///   - latitude: Geographic latitude coordinate
  ///   - longitude: Geographic longitude coordinate
  ///   - microphone: Available microphone types
  ///   - name: Display name of the room
  ///   - school: School or faculty that manages the room
  ///   - seating: Type of seating arrangement
  ///   - usage: Intended use of the room
  ///   - service: Additional services available
  ///   - writingMedia: Available writing surfaces
  ///   - building: Reference to the parent SwiftDataBuilding
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
    writingMedia: [String])
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

  public var stringID: String {
    id
  }

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
