//
//  MockBuildingService.swift
//  Buildings
//
//  Created by Shabinda Sarkaria on 13/6/2025.
//

import BuildingModels
import BuildingServices

// MARK: - MockBuildingService

class MockBuildingService: BuildingService {

  // MARK: Internal

  func getBuildings() async -> GetBuildingsResult {
    .success(buildings)
  }

  func addBuilding(_ building: Building) {
    buildings.append(building)
  }

  func clearBuildings() {
    buildings.removeAll()
  }

  // MARK: Private

  private var buildings: [Building] = []

}
