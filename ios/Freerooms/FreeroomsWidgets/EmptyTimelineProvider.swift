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
    var date: Date = Date()
  }
  
  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
    completion(Entry())
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    completion(Timeline(entries: [Entry()], policy: .never))
  }
  
  func placeholder(in context: Context) -> Entry {
    Entry()
  }
  
}
