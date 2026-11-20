//
//  EmptyTimelineProvider.swift
//  Freerooms
//
//  Created by Matthew Yuen on 28/8/2026.
//

import Foundation
import WidgetKit

struct EmptyTimelineProvider: TimelineProvider {

  struct Entry: TimelineEntry {
    let date = Date()
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
