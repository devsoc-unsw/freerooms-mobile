//
//  OpenTabWidget.swift
//  Freerooms
//
//  Created by Matthew Yuen on 28/8/2026.
//

import SwiftUI
import WidgetKit
import AppIntents
import FreeroomsIntents
import CommonUI

struct OpenTabWidget: Widget {
  let kind = "OpenTabWidget"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: EmptyTimelineProvider()) { _ in
      VStack {
      }
    }
    .configurationDisplayName("Open Tab")
    .description("Convenient way to open a tab")
  }
  
}

#Preview(as: .systemSmall) {
  OpenTabWidget()
} timeline: {
  EmptyTimelineProvider.Entry()
}
