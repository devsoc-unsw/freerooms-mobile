//
//  GridReference.swift
//  Location
//
//  Created by Yanlin Li  on 5/9/2025.
//

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
