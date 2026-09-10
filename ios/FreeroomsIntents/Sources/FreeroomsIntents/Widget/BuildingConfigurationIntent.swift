//
//  BuildingConfigurationIntent.swift
//  Freerooms
//
//  Created by Matthew Yuen on 7/9/2026.
//

import AppIntents
import WidgetKit
import BuildingModels

public struct BuildingConfigurationIntent: WidgetConfigurationIntent {
  static public let title: LocalizedStringResource = "Building"
  static public let description = "Shows the current status of a building"

  @Parameter(title: "Building")
  public var building: BuildingEntity?
  
//  public var building: BuildingEntity? {
//    Building(
//      name: "Morven Brown Building",
//      id: "K-C20",
//      latitude: -33.916792,
//      longitude: 151.232828,
//      aliases: [],
//      numberOfAvailableRooms: 15).appEntity
//  }

  public init() { }
}
