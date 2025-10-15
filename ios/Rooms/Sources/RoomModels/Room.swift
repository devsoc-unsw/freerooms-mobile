//
//  Room.swift
//  Persistence
//
//  Created by Chris Wong on 26/6/2025.
//

// MARK: - Room
import Location

public struct Room: Equatable, Identifiable, Hashable {

  // MARK: Lifecycle

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
    status: String? = nil,
    endTime: String? = nil,
    overallRating: Double? = nil)
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
    self.status = status ?? ""
    self.endTime = endTime ?? ""
    self.overallRating = overallRating
  }

  // MARK: Public

  static public let exampleOne = Room(
    abbreviation: "Col LG01",
    accessibility: [
      "Ventilation - Air conditioning",
      "Weekend Access",
      "Wheelchair access - teaching",
      "Wheelchair access - student",
      "Power at Wall",
    ],
    audioVisual: [
      "Document camera",
    ],
    buildingId: "K-B16",
    capacity: 48,
    floor: "Flat",
    id: "K-B16-LG01",
    infoTechnology: [
      "IT laptop connection",
      "IT Lectern",
      "Video data projector",
      "Web Camera with Microphone",
    ],
    latitude: -33.916155183912196,
    longitude: 151.23130187740358,
    microphone: [
      "IT laptop connection",
      "IT Lectern",
      "Video data projector",
      "Web Camera with Microphone",
    ],
    name: "Colombo LG01",
    school: "UNSW",
    seating: "Movable",
    usage: "TUSM",
    service: [],
    writingMedia: [
      "Whiteboard",
    ])

  static public let exampleTwo = Room(
    abbreviation: "Col LG02",
    accessibility: [
      "Ventilation - Air conditioning",
      "Weekend Access",
      "Wheelchair access - teaching",
      "Wheelchair access - student",
      "Power at Wall",
    ],
    audioVisual: [
      "Document camera",
    ],
    buildingId: "K-B16",
    capacity: 56,
    floor: "Flat",
    id: "K-B16-LG02",
    infoTechnology: [
      "Hybrid Teaching Space",
      "Lecture capture venue",
      "IT laptop connection",
      "IT Lectern",
      "Video data projector",
    ],
    latitude: -33.91602605723141,
    longitude: 151.2313272230597,
    microphone: [
      "Dual Radio Microphones",
    ],
    name: "Colombo LG02",
    school: "UNSW",
    seating: "Movable",
    usage: "TUSM",
    service: [],
    writingMedia: [
      "Whiteboard",
    ])

  public let abbreviation: String
  public let accessibility: [String]
  public let audioVisual: [String]
  public let buildingId: String
  public let capacity: Int
  public let floor: String?
  public let id: String
  public let infoTechnology: [String]
  public let latitude: Double
  public let longitude: Double
  public let microphone: [String]
  public let name: String
  public let school: String
  public let seating: String?
  public let usage: String
  public let service: [String]
  public let writingMedia: [String]
  public var status: String?
  public var endTime: String?
  public var overallRating: Double?

  /// Computed grid reference based on the building ID for campus organization
  public var gridReference: GridReference {
    GridReference.fromBuildingID(buildingID: buildingId)
  }

  /// Computed room number based on the room ID
  public var roomNumber: String {
    let splitID = id.split(separator: "-").map { String($0) }
    guard splitID.count == 3 else { return "?" }
    return splitID[2]
  }
}
