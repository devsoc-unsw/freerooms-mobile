//
//  MockBuildingService.swift
//  Buildings
//
//  Created by Shabinda Sarkaria on 13/6/2025.
//

import BuildingModels
import BuildingServices

// MARK: - MockBuildingService

public class MockBuildingService: BuildingService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getBuildings() -> GetBuildingsResult {
    .success(buildings)
  }

  public func reloadBuildings() -> GetBuildingsResult {
    .success(buildings)
  }

  public func addBuilding(_ building: Building) {
    buildings.append(building)
  }

  public func clearBuildings() {
    buildings.removeAll()
  }

  public func stubSuccess(_ buildings: [Building]) {
    self.buildings = buildings
  }

  // MARK: Private

  private var buildings = [Building]()
}
