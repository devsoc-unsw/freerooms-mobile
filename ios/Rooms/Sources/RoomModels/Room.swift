//
//  Room.swift
//  Persistence
//
//  Created by Chris Wong on 26/6/2025.
//

public struct Room: Equatable, Identifiable, Hashable {

  // MARK: Lifecycle

  public init(
    abbreviation: String,
    accessibility: String,
    audioVisual: String,
    buildingId: String,
    capacity: Int,
    floor: String,
    id: String,
    latitude: Double,
    longitude: Double,
    microphone: [String],
    name: String,
    school: String,
    seating: String,
    usage: String,
    service: [String],
    writingMedia: [String])
  {
    self.abbreviation = abbreviation
    self.accessibility = accessibility
    self.audioVisual = audioVisual
    self.buildingId = buildingId
    self.capacity = capacity
    self.floor = floor
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.microphone = microphone
    self.name = name
    self.school = school
    self.seating = seating
    self.usage = usage
    self.service = service
    self.writingMedia = writingMedia
  }

  // MARK: Public

  public let abbreviation: String
  public let accessibility: String
  public let audioVisual: String
  public let buildingId: String
  public let capacity: Int
  public let floor: String
  public let id: String
  public let latitude: Double
  public let longitude: Double
  public let microphone: [String]
  public let name: String
  public let school: String
  public let seating: String
  public let usage: String
  public let service: [String]
  public let writingMedia: [String]
  
}
