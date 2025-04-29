//
//  MapViewModel.swift
//  Freerooms
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 26/4/25.
//

import Buildings
import Foundation
import Observation

@Observable
final class MapViewModel {

  // MARK: Lifecycle

  /// Custom BuildingService (for example, a mock for testing), or use the default one for normal app usage.
  init(buildingService: BuildingService = BuildingService()) {
    self.buildingService = buildingService
  }

  // MARK: Internal

  var buildings: [Building] = []

  func loadBuildings() {
    buildings = buildingService.getBuildings()
  }

  // MARK: Private

  private let buildingService: BuildingService

}
