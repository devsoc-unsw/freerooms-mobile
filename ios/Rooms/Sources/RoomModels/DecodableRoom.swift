//
//  DecodableRoom.swift
//  Persistence
//
//  Created by Chris Wong on 15/8/2025.
//

public struct DecodableRoom: Decodable, Equatable {

  // MARK: Lifecycle

  public init(
    abbr: String,
    accessibility: [String],
    audiovisual: [String],
    buildingId: String,
    capacity: Int,
    floor: String?,
    id: String,
    infotechnology: [String],
    lat: Double,
    long: Double,
    microphone: [String],
    name: String,
    school: String,
    seating: String?,
    usage: String,
    service: [String],
    writingMedia: [String])
  {
    self.abbr = abbr
    self.accessibility = accessibility
    self.audiovisual = audiovisual
    self.buildingId = buildingId
    self.capacity = capacity
    self.floor = floor ?? ""
    self.id = id
    self.infotechnology = infotechnology
    self.lat = lat
    self.long = long
    self.microphone = microphone
    self.name = name
    self.school = school
    self.seating = seating ?? ""
    self.usage = usage
    self.service = service
    self.writingMedia = writingMedia
  }

  // MARK: Public

  public let abbr: String
  public let accessibility: [String]
  public let audiovisual: [String]
  public let buildingId: String
  public let capacity: Int
  public let floor: String?
  public let id: String
  public let infotechnology: [String]
  public let lat: Double
  public let long: Double
  public let microphone: [String]
  public let name: String
  public let school: String
  public let seating: String?
  public let usage: String
  public let service: [String]
  public let writingMedia: [String]

}
