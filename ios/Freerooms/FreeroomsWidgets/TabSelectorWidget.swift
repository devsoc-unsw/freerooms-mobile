//
//  TabSelectorWidget.swift
//  Freerooms
//
//  Created by Matthew Yuen on 14/6/2026.
//

import AppIntents
import CommonUI
import SwiftUI
import WidgetKit

enum TabSelectorWidget {

  struct TimelineProvider: WidgetKit.TimelineProvider {

    struct Entry: TimelineEntry {
      var date: Date = Date()
      var relevance: TimelineEntryRelevance? { nil }
    }

    func getSnapshot(in _: Context, completion: @escaping (Entry) -> Void) {
      completion(Entry())
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
      completion(Timeline(entries: [Entry()], policy: .never))
    }

    func placeholder(in _: Context) -> Entry {
      Entry()
    }

  }

  struct Widget: SwiftUI.Widget {
    static let kind: String = "Tab Selector"

    var body: some WidgetConfiguration {
      StaticConfiguration(kind: Self.kind, provider: TimelineProvider()) { _ in
        VStack {
          Button("Buildings", intent: OpenBuildingsTabIntent())
          Button("Map", intent: OpenMapTabIntent())
          Button("Rooms", intent: OpenRoomsTabIntent())
        }
      }
    }
  }

}
