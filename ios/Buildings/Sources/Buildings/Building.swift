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
    GridReference.fromBuildingId(buildingId: id)
  }

}

// MARK: - GridReference

public struct GridReference {
  public let campusCode: String
  public let sectionCode: String
  public let sectionNumber: Int
  public let campusSection: CampusSection

  public static func fromBuildingId(buildingId: String) -> GridReference? {
    let splitId = buildingId.split(separator: "-").map { String($0) }
    guard splitId.count >= 2 else { return nil }

    let campus = splitId[0]
    let section = splitId[1]

    do {
      // regex grouping:
      // 1. number for sectionNumber
      // 2. letter for sectionCode
      let regex = try NSRegularExpression(pattern: "([A-Z]+)([0-9]+)")
      let range = NSRange(section.startIndex..<section.endIndex, in: section)

      if let match = regex.firstMatch(in: section, range: range) {
        let sectionLetter = String(section[Range(match.range(at: 1), in: section)!])
        let sectionNumberStr = String(section[Range(match.range(at: 2), in: section)!])

        guard let sectionNumber = Int(sectionNumberStr) else { return nil }
        let campusSection = CampusSection.fromNumber(sectionNumber)

        return GridReference(
          campusCode: campus,
          sectionCode: sectionLetter,
          sectionNumber: sectionNumber,
          campusSection: campusSection)
      }
    } catch {
      print("Regex error: \(error)")
    }

    return nil
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
