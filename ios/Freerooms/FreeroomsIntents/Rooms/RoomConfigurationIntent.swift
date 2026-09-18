//
//  RoomConfigurationIntent.swift
//  Freerooms
//
//  Created by Matthew Yuen on 19/9/2026.
//

import AppIntents
import WidgetKit

struct RoomConfigurationIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Configure Room"
  static let description = IntentDescription("Shows the current status of a room")

  @Parameter(
    title: "Room",
    description: "The room to show")
  var room: RoomWidgetConfigurationEntity?

  init(room: RoomWidgetConfigurationEntity) {
    self.room = room
  }

  init() { }

  static var parameterSummary: some ParameterSummary {
    Summary("\(\.$room)")
  }
}
