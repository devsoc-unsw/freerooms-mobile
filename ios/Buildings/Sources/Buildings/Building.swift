//
//  Building.swift
//  Buildings
//
//  Created by Anh Nguyen on 12/1/2025.
//

import Foundation

// MARK: - Building

public struct Building: Equatable {

  // MARK: Lifecycle

  public init(name: String, id: String, latitude: Double, longitude: Double, aliases: [String], numberOfAvailableRooms: Int?) {
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

  public var gridReference: GridReference? {
    GridReference.fromBuildingID(buildingID: id)
  }

}

// MARK: - GridReference

public struct GridReference {
  public let campusCode: String
  public let sectionCode: String
  public let sectionNumber: Int
  public let campusSection: CampusSection

  public static func fromBuildingID(buildingID: String) -> GridReference? {
    let splitID = buildingID.split(separator: "-").map { String($0) }
    guard splitID.count == 2 else { return nil }

    let campusCode = splitID[0]
    let section = splitID[1]

    let startIndex = section.startIndex
    let secondIndex = section.index(after: startIndex)

    let sectionLetter = String(section[startIndex])
    guard let sectionNumber = Int(String(section[secondIndex...])) else {
      return nil
    }

    let campusSection = CampusSection.fromNumber(sectionNumber)

    return GridReference(
      campusCode: campusCode,
      sectionCode: sectionLetter,
      sectionNumber: sectionNumber,
      campusSection: campusSection)
  }
}

// MARK: - CampusSection

public enum CampusSection: Comparable {
  case lower
  case middle
  case upper

  // MARK: Internal

  static func fromNumber(_ number: Int) -> CampusSection {
    switch number {
    case lowerRange:
      .lower
    case middleRange:
      .middle
    case upperRange:
      .upper
    default:
      .upper
    }
  }

  // MARK: Private

  // Define the ranges
  // range taken from https://maps-sydney.com/maps-sydney-others/unsw-map
  private static let lowerRange = 1...10
  private static let middleRange = 11...18
  private static let upperRange = 19...28

}
