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
  }

  // MARK: Public

  public let name: String
  public let id: String
  public let latitude: Double
  public let longitude: Double
  public let aliases: [String]
  public var numberOfAvailableRooms: Int?
  public var overallRating: Double?

  /// Computed grid reference based on the building ID for campus organization
  public var gridReference: GridReference {
    GridReference.fromBuildingID(buildingID: id)
  }

}
