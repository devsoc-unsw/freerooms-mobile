//
//  RemoteBuildingRatingResponse.swift
//  Buildings
//
//  Created by Chris Wong on 11/9/2025.
//

public struct RemoteBuildingRatingResponse: Codable {
  public let buildingId: String
  public let overallRating: Double

  public init(buildingId: String, overallRating: Double) {
    self.buildingId = buildingId
    self.overallRating = overallRating
  }
}
