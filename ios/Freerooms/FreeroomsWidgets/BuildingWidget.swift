//
//  BuildingWidget.swift
//  Freerooms
//
//  Created by Matthew Yuen on 10/9/2026.
//

import SwiftUI
import WidgetKit
import CommonUI
import BuildingModels
import BuildingViews

struct BuildingWidget: Widget {
  static let kind: String = "BuildingWidget"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: Self.kind, provider: BuildingTimelineProvider(), content: _View.init(entry:))
      .contentMarginsDisabled()
  }
  
  private struct _View: View {
    let entry: BuildingTimelineProvider.Entry
    let theme = Theme.default
    
    @Environment(\.widgetContentMargins) private var contentMargins
    @Environment(\.widgetFamily) private var family
    
    init(entry: BuildingTimelineProvider.Entry) {
      self.entry = entry
    }
    
    var body: some View {
      Group {
        switch entry.value {
        case .missingBuilding:
          ContentUnavailableView("No Selected Building", systemImage: "building", description: Text("Select a building to display"))
        case .failed(let error):
          ContentUnavailableView("Could not load building", systemImage: "exclamationmark.triangle", description: Text(error.localizedDescription))
        case .building(let building, let image):
          makeView(for: building, image: image)
        }
      }
      .containerBackground(.clear, for: .widget)
    }
    
    @ViewBuilder
    private func makeView(for building: Building, image: Image?) -> some View {
      (image ?? Image(systemName: "building"))
        .resizable()
        .scaledToFill()
    }
    
  }
  
}

#Preview("System Large", as: .systemLarge) {
  BuildingWidget()
} timeline: {
  BuildingTimelineProvider.Entry.failed(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError))
  BuildingTimelineProvider.Entry.missingBuilding
  BuildingTimelineProvider.Entry.placeholder
}
