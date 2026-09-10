//
//  BuildingConfigurationIntent.swift
//  Freerooms
//
//  Created by Matthew Yuen on 7/9/2026.
//

import AppIntents
import FreeroomsIntents
import WidgetKit

public struct BuildingConfigurationIntent: WidgetConfigurationIntent {
  static public let title: LocalizedStringResource = "Building"

  @Parameter(title: "Building")
  public var building: BuildingEntity?

  public init() { }

  static public var parameterSummary: some ParameterSummary {
    Summary {
      \.$building
    }
  }
}
