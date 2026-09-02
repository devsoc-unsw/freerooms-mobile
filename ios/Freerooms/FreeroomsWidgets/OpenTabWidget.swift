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
      View()
    }
    .configurationDisplayName("Open Tab")
    .description("Convenient way to open a tab")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
  
  private struct View: SwiftUI.View {
    private let theme = Theme.default
    @Environment(\.widgetFamily) private var family
    
    var body: some SwiftUI.View {
      Grid {
        GridRow {
          buildButton("Buildings", for: TabIntents.Buildings(), imageSystemName: "building")
          buildButton("Map", for: TabIntents.Map(), imageSystemName: "map")
        }
        GridRow {
          buildButton("Rooms", for: TabIntents.Rooms(), imageSystemName: "door.left.hand.open")
          buildButton("Bookings", for: TabIntents.Bookings(), imageSystemName: "book.closed")
        }
      }
      .buttonBorderShape(.roundedRectangle)
      .containerBackground(for: .widget) {
        Color.clear
      }
    }
    
    @ViewBuilder
    private func buildButton(
      _ title: LocalizedStringResource,
      for intent: some AppIntent,
      imageSystemName: String
    ) -> some SwiftUI.View {
      Group {
        switch family {
        case .systemSmall:
          Button(intent: intent) {
            Image(systemName: imageSystemName)
              .resizable()
              .scaledToFit()
              .foregroundStyle(theme.accent.primary)
              .padding(2.0)
              .frame(maxWidth: .infinity, maxHeight: .infinity) // nasty hack :(
          }
        case .systemMedium:
          Button(intent: intent) {
            Label(title, systemImage: imageSystemName)
              .font(.title2)
              .bold()
              .foregroundStyle(theme.accent.primary)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        default:
          preconditionFailure("\(#function): Unexpected widget family")
        }
      }
      .buttonStyle(.bordered)
      .tint(theme.accent.secondary)
    }
    
  }

}

#Preview("System Small", as: .systemSmall) {
  OpenTabWidget()
} timeline: {
  EmptyTimelineProvider.Entry()
}

#Preview("System Medium", as: .systemMedium) {
  OpenTabWidget()
} timeline: {
  EmptyTimelineProvider.Entry()
}
