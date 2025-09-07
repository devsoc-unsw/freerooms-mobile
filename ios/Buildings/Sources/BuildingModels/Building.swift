//
//  Building.swift
//  Buildings
//
//  Created by Anh Nguyen on 12/1/2025.
//

import Foundation

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
  }

  // MARK: Public

  public let name: String
  public let id: String
  public let latitude: Double
  public let longitude: Double
  public let aliases: [String]
  public let numberOfAvailableRooms: Int?

  /// Computed grid reference based on the building ID for campus organization
  public var gridReference: GridReference {
    GridReference.fromBuildingID(buildingID: id)
  }

}

// MARK: - GridReference

/// Represents the campus grid location of a building based on its ID.
public struct GridReference {
  public let campusCode: String
  public let sectionCode: String
  public let sectionNumber: Int
  public let campusSection: CampusSection

  /// Creates a grid reference by parsing a building ID.
  /// - Parameter buildingID: Building identifier in format "Campus-SectionNumber" (e.g., "K-J17")
  /// - Returns: GridReference with parsed campus and section information
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

/// Represents the vertical campus section based on building numbers.
public enum CampusSection: Int {
  case lower, middle, upper

  // MARK: Lifecycle

  /// Creates a campus section based on building number ranges.
  /// Ranges taken from https://maps-sydney.com/maps-sydney-others/unsw-map
  /// - Parameter rawValue: Building number to classify
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
