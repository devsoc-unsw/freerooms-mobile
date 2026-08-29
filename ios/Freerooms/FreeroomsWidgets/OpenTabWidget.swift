//
//  OpenTabWidget.swift
//  Freerooms
//
//  Created by Matthew Yuen on 28/8/2026.
//

import AppIntents
import CommonUI
import FreeroomsIntents
import SwiftUI
import WidgetKit

struct OpenTabWidget: Widget {
  let kind = "OpenTabWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: EmptyTimelineProvider()) { _ in
      VStack {
        Button("Buildings", intent: TabIntents.OpenTabIntentBuildings())
        Button("Map", intent: TabIntents.OpenTabIntentMap())
        Button("Rooms", intent: TabIntents.OpenTabIntentRooms())
        Button("Bookings", intent: TabIntents.OpenTabIntentBookings())
      }
    }
    .configurationDisplayName("Open Tab")
    .description("Convenient way to open a tab")
    .supportedFamilies([.systemSmall])
  }

}

#Preview(as: .systemSmall) {
  OpenTabWidget()
} timeline: {
  EmptyTimelineProvider.Entry()
}
