//
//  BuildingInteractor.swift
//  Buildings
//
//  Created by Anh Nguyen on 27/4/2025.
//

import Foundation

final class BuildingInteractor {

  // MARK: Lifecycle

  init(buildingService: BuildingServiceProtocol) {
    self.buildingService = buildingService
  }

  // MARK: Internal

  func getBuildingsSortedByAvailableRooms() -> [Building] {
    fatalError("TODO: Implement")
  }

  func getBuildingsSortedAlphabetically(inAscendingOrder _: Bool) -> [Building] {
    fatalError("TODO: Implement")
  }

  func getBuildingsSortedByDistance(inAscendingOrder _: Bool) -> [Building] {
    fatalError("TODO: Implement")
  }

  func getBuildingSortedByCampusSection(inAscendingOrder: Bool) -> [Building] {
    var buildings = buildingService.getBuildings()

    if inAscendingOrder {
      buildings = buildings.sorted { $0.gridReference!.campusSection < $1.gridReference!.campusSection }
    } else {
      buildings = buildings.sorted { $0.gridReference!.campusSection > $1.gridReference!.campusSection }
    }

    return buildings
  }

  // MARK: Private

  private let buildingService: BuildingServiceProtocol

}
