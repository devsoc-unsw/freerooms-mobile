//
//  BuildingConfigurationIntent.swift
//  Freerooms
//
//  Created by Matthew Yuen on 7/9/2026.
//

import AppIntents
import WidgetKit
import BuildingModels
import FreeroomsEntities

struct BuildingConfigurationIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Building"
  static let description = IntentDescription("Shows the current status of a building")

  @Parameter(
    title: "Building",
    description: "The building to show")
  var building: BuildingWidgetConfigurationEntity?
  
  init(building: BuildingWidgetConfigurationEntity) {
    self.building = building
  }
  
  init() {}
  
  static var parameterSummary: some ParameterSummary {
    Summary("\(\.$building)")
  }
}
