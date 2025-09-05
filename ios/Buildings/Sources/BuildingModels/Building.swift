//
//  Building.swift
//  Buildings
//
//  Created by Anh Nguyen on 12/1/2025.
//

import Foundation
import Location

// MARK: - Building

/// A building on campus with location information and room availability data.
public struct Building: Equatable, Identifiable, Hashable {

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

  public static func getBuildingIDs() -> [String] {
    [
      "K-G27",
      "K-J17",
      "K-H13",
      "K-E26",
      "K-D26",
      "K-G6",
      "K-E12",
      "K-H20",
      "K-B16",
      "K-K17",
      "K-F12",
      "K-G17",
      "K-D8",
      "K-D16",
      "K-F25",
      "K-F31",
      "K-F20",
      "K-G19",
      "K-F10",
      "K-J14",
      "K-F8",
      "K-F21",
      "K-E10",
      "K-F23",
      "K-D23",
      "K-C20",
      "K-J12",
      "K-K15",
      "K-E19",
      "K-K14",
      "K-E15",
      "K-F17",
      "K-M15",
      "K-E8",
      "K-F13",
      "K-C24",
      "K-E4",
      "K-H6",
      "K-H22",
      "K-C27",
      "K-G14",
      "K-G15",
      "K-J18",
    ]
  }
}
