//
//  RemoteBuilding.swift
//  Buildings
//
//  Created by Chris Wong on 29/4/2025.
//

import Foundation

public struct RemoteBuilding: Equatable, Codable {
  public let buildingName: String
  public let buildingId: UUID
  public let buildingLatitude: Double
  public let buildingLongitude: Double
  public let buildingAliases: [String]

  public init(
    buildingName: String,
    buildingId: UUID,
    buildingLatitude: Double,
    buildingLongitude: Double,
    buildingAliases: [String])
  {
    self.buildingName = buildingName
    self.buildingId = buildingId
    self.buildingLatitude = buildingLatitude
    self.buildingLongitude = buildingLongitude
    self.buildingAliases = buildingAliases
  }
}
