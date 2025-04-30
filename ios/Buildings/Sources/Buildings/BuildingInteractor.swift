//
//  BuildingInteractor.swift
//  Buildings
//
//  Created by Anh Nguyen on 27/4/2025.
//

import Foundation
import Location

final class BuildingInteractor {

  // MARK: Lifecycle

  init(buildingService: BuildingService = .init(),
       locationService: LocationService = .init()) {
    self.buildingService = buildingService
    self.locationService = locationService
  }

  // MARK: Internal

  func getBuildingsSortedByAvailableRooms() -> [Building] {
    fatalError("TODO: Implement")
  }

  func getBuildingsSortedAlphabetically(inAscendingOrder: Bool) -> [Building] {
    fatalError("TODO: Implement")
  }

  func getBuildingsSortedByDistance(inAscendingOrder: Bool) -> Result<[Building], Error> {
    let buildings = buildingService.getBuildings()

    do {
      let currentLocation = try locationService.getCurrentLocation()

      // Compute each building’s distance once, then sort
      let sorted = buildings
        .map { building -> (Building, Double) in
          (building, calculateDistance(from: currentLocation, to: building))
        }
        .sorted { inAscendingOrder ? $0.1 < $1.1 : $0.1 > $1.1 }
        .map { $0.0 }

      return .success(sorted)
    } catch {
      return .failure(error)
    }
  }

  // MARK: Private

  private let buildingService: BuildingService
  private let locationService: LocationService

  
  private func calculateDistance(from location: Location, to building: Building) -> Double {
    let dlat = building.latitude  - location.latitude
    let dlon = building.longitude - location.longitude
    return sqrt(dlat * dlat + dlon * dlon)
  }
}
