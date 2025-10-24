//
//  MockBuildingRatingLoader.swift
//  Buildings
//
//  Created by Chris Wong on 11/9/2025.
//

import BuildingServices

public struct MockBuildingRatingLoader: BuildingRatingLoader {
  init(loads rating: Double = 0, throws error: BuildingRatingLoaderError? = nil) {
    self.rating = rating
    self.error = error
  }

  // MARK: Internal

  let rating: Double
  let error: BuildingRatingLoaderError?

  public func fetch(buildingID _: String) -> Result<Double, BuildingRatingLoaderError> {
    if error != nil {
      return .failure(error!)
    }

    return .success(rating)
  }

}
