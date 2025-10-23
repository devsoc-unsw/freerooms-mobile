//
//  Building.swift
//  Buildings
//
//  Created by Anh Nguyen on 12/1/2025.
//

import Foundation

// MARK: - Building

public struct Building: Equatable, Identifiable, Hashable, Sendable {

  // MARK: Lifecycle

  public init(
    name: String,
    id: String,
    latitude: Double,
    longitude: Double,
    aliases: [String],
    numberOfAvailableRooms: Int? = nil)
  {
    self.name = name
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.aliases = aliases
    self.numberOfAvailableRooms = numberOfAvailableRooms
    availabilityStatus = AvailabilityStatus(numberOfAvailableRooms)
  }

  // MARK: Public

  public let name: String
  public let id: String
  public let latitude: Double
  public let longitude: Double
  public let aliases: [String]
  public let numberOfAvailableRooms: Int?

  public var availabilityStatus: AvailabilityStatus

  public var gridReference: GridReference {
    GridReference.fromBuildingID(buildingID: id)
  }

}

// MARK: - GridReference

public struct GridReference {
  public let campusCode: String
  public let sectionCode: String
  public let sectionNumber: Int
  public let campusSection: CampusSection

  public static func fromBuildingID(buildingID: String) -> GridReference {
    let splitID = buildingID.split(separator: "-").map { String($0) }
    guard splitID.count == 2 else { return defaultGridReference() }

    let campusCode = splitID[0]
    let section = splitID[1]

    let startIndex = section.startIndex
    let secondIndex = section.index(after: startIndex)

    let sectionLetter = String(section[startIndex])
    guard let sectionNumber = Int(String(section[secondIndex...])) else {
      return defaultGridReference()
    }

    let campusSection = CampusSection(sectionNumber)

    return GridReference(
      campusCode: campusCode,
      sectionCode: sectionLetter,
      sectionNumber: sectionNumber,
      campusSection: campusSection)
  }

  public static func defaultGridReference() -> GridReference {
    GridReference(
      campusCode: "?",
      sectionCode: "?",
      sectionNumber: 0,
      campusSection: .upper)
  }
}

// MARK: - CampusSection

public enum CampusSection: Int {
  case lower, middle, upper

  // MARK: Lifecycle

  /// ranges taken from https://maps-sydney.com/maps-sydney-others/unsw-map
  public init(_ rawValue: Int) {
    switch rawValue {
    case 1...10:
      self = .lower
    case 11...18:
      self = .middle
    case 19...28:
      self = .upper
    default:
      self = .upper
    }
  }

}

// MARK: - AvailabilityStatus

public enum AvailabilityStatus: String, Sendable {

  case available, crowded, unavailable, missing

  public init(_ rawValue: Int?) {
    guard let rawValue else {
      self = .missing
      return
    }

    switch rawValue {
    case 5...:
      self = .available
    case 1...4:
      self = .crowded
    case 0:
      self = .unavailable
    default:
      self = .missing
    }
  }
}
