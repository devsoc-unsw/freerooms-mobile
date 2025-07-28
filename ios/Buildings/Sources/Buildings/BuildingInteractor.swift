//
//  BuildingInteractor.swift
//  Buildings
//
//  Created by Anh Nguyen on 27/4/2025.
//

import Foundation
import Location

package final class BuildingInteractor {

  // MARK: Lifecycle

  package init(buildingService: BuildingService, locationService: LocationService) {
    self.buildingService = buildingService
    self.locationService = locationService
  }

  // MARK: Package

  package func getBuildingsSortedAlphabetically(inAscendingOrder: Bool) async -> Result<[Building], Error> {
    switch await buildingService.getBuildings() {
    case .success(let buildings):
      let sorted = buildings.sorted { a, b in
        inAscendingOrder ? a.name < b.name : a.name > b.name
      }
      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  // MARK: Internal

  func getBuildingsSortedByAvailableRooms(inAscendingOrder: Bool) async -> Result<[Building], Error> {
    switch await buildingService.getBuildings() {
    case .success(let buildings):
      // no valid data, return as is
      guard buildings.contains(where: { $0.numberOfAvailableRooms != nil }) else {
        return .success(buildings)
      }
      let sorted = buildings.sorted { (a: Building, b: Building) in
        inAscendingOrder
          ? (a.numberOfAvailableRooms ?? 0) < (b.numberOfAvailableRooms ?? 0)
          : (a.numberOfAvailableRooms ?? 0) > (b.numberOfAvailableRooms ?? 0)
      }
      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  func getBuildingsSortedByDistance(inAscendingOrder: Bool) async -> Result<[Building], Error> {
    switch await buildingService.getBuildings() {
    case .success(let buildings):
      do {
        let currentLocation = try locationService.getCurrentLocation()

        // Compute each building’s distance once, then sort
        let sorted = buildings
          .map { (building: Building) -> (Building, Double) in
            (building, calculateDistance(from: currentLocation, to: building))
          }
          .sorted { inAscendingOrder ? $0.1 < $1.1 : $0.1 > $1.1 }
          .map { $0.0 }
        return .success(sorted)
      } catch {
        return .failure(error)
      }

    case .failure(let error):
      return .failure(error)
    }
  }

  func getBuildingSortedByCampusSection(inAscendingOrder: Bool) async -> Result<[Building], Error> {
    switch await buildingService.getBuildings() {
    case .success(let buildings):
      var sorted = buildings
      if inAscendingOrder {
        sorted = buildings.sorted { $0.gridReference.campusSection.rawValue < $1.gridReference.campusSection.rawValue }
      } else {
        sorted = buildings.sorted { $0.gridReference.campusSection.rawValue > $1.gridReference.campusSection.rawValue }
      }

      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  // MARK: Private

  private let buildingService: BuildingService
  private let locationService: LocationService

  private func calculateDistance(from location: Location, to building: Building) -> Double {
    let dlat = building.latitude - location.latitude
    let dlon = building.longitude - location.longitude
    return dlat * dlat + dlon * dlon
  }

}
