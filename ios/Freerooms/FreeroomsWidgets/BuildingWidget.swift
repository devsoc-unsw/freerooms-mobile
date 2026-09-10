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
      .supportedFamilies([.systemMedium, .systemLarge])
      .polyfillPromptsForUserConfiguration()
  }
  
  private struct _View: View {
    let entry: BuildingTimelineProvider.Entry
    let theme = Theme.default
    
    @Environment(\.widgetContentMargins) private var contentMargins
    @Environment(\.widgetFamily) private var family
    
    private var building: Building! {
      guard case .building(let building, _) = entry.value else { return nil }
      return building
    }
    
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
      // https://stackoverflow.com/questions/73707062/how-to-scale-an-image-to-fill-the-parent-view-without-affecting-the-layout-in-sw
      Color.clear
        .overlay {
          (image ?? Image(systemName: "building"))
            .resizable()
            .scaledToFill()
        }
        .clipped()
        .overlay(alignment: .bottom) {
          VStack(alignment: .leading) {
            Text(building.name)
              .font(.title3)
              .bold()
            if let availableRooms = building.numberOfAvailableRooms {
              Text("\(availableRooms) rooms available")
            } else {
              Text("Unknown rooms available")
            }
          }
          .padding(4.0)
          .frame(maxWidth: .infinity)
          .background {
            ContainerRelativeShape()
              .foregroundStyle(.white)
          }
          .padding(contentMargins)
        }
    }
    
  }
  
}

#Preview("System Medium", as: .systemMedium) {
  BuildingWidget()
} timeline: {
  BuildingTimelineProvider.Entry.failed(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError))
  BuildingTimelineProvider.Entry.missingBuilding
  BuildingTimelineProvider.Entry.placeholder
}

#Preview("System Large", as: .systemLarge) {
  BuildingWidget()
} timeline: {
  BuildingTimelineProvider.Entry.failed(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError))
  BuildingTimelineProvider.Entry.missingBuilding
  BuildingTimelineProvider.Entry.placeholder
}
