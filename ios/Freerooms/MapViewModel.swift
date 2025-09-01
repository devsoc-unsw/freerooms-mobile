//
//  MapViewModel.swift
//  Freerooms
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 26/4/25.
//

import BuildingModels
import BuildingServices
import Foundation
import Observation

@Observable
final class MapViewModel {

  // MARK: Lifecycle

  /// Custom BuildingService (for example, a mock for testing), or use the default one for normal app usage.
  init(buildingService: BuildingService) {
    self.buildingService = buildingService
  }

  // MARK: Internal

  var buildings: [Building] = []

  func loadBuildings() async throws(FetchBuildingsError) {
    switch buildingService.getBuildings() {
    case .success(let buildings):
      self.buildings = buildings
    case .failure(let error):
      throw error
    }
  }

  // MARK: Private

  private let buildingService: BuildingService

}
