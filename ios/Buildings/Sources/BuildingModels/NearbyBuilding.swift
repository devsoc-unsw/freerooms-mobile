//
//  NearbyBuilding.swift
//  Buildings
//
//  Created by Eric Wong on 11/11/2026.
//

// MARK: - NearbyBuilding

/// A building paired with how far it is from the user.
public nonisolated
struct NearbyBuilding: Equatable, Identifiable, Hashable, Sendable {

  // MARK: Lifecycle

  public init(building: Building, distanceInMetres: Double) {
    self.building = building
    self.distanceInMetres = distanceInMetres
  }

  // MARK: Public

  public let building: Building
  /// Straight-line distance from the user, in metres.
  public let distanceInMetres: Double

  public var id: String {
    building.id
  }
}
