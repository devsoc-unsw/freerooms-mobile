//
//  Building.swift
//  Buildings
//
//  Created by Anh Nguyen on 12/1/2025.
//

import Foundation
import Location

// MARK: - Building

public typealias CampusBuildings = (upper: [Building], middle: [Building], lower: [Building])

// MARK: - Building

/// A building on campus with location information and room availability data.
public struct Building: Equatable, Identifiable, Hashable, Sendable {

  // MARK: Lifecycle

  /// Creates a new building with the specified properties.
  /// - Parameters:
  ///   - name: The display name of the building
  ///   - id: Unique identifier for the building (e.g., "K-J17")
  ///   - latitude: Geographic latitude coordinate
  ///   - longitude: Geographic longitude coordinate
  ///   - aliases: Alternative names or abbreviations for the building
  ///   - numberOfAvailableRooms: Optional count of currently available rooms
  ///   - overallRating: Optional overall rating of current building based on rated rooms
  public init(
    name: String,
    id: String,
    latitude: Double,
    longitude: Double,
    aliases: [String],
    numberOfAvailableRooms: Int? = nil,
    overallRating: Double? = nil)
  {
    self.name = name
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.aliases = aliases
    self.numberOfAvailableRooms = numberOfAvailableRooms
    self.overallRating = overallRating
    availabilityStatus = AvailabilityStatus(numberOfAvailableRooms)
  }

  // MARK: Public

  public let name: String
  public let id: String
  public let latitude: Double
  public let longitude: Double
  public let aliases: [String]
  public var numberOfAvailableRooms: Int?
  public var overallRating: Double?

  public var availabilityStatus: AvailabilityStatus

  /// Computed grid reference based on the building ID for campus organization
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
