//
//  BuildingWidget.swift
//  Freerooms
//
//  Created by Matthew Yuen on 10/9/2026.
//

import BuildingModels
import BuildingViews
import CommonUI
import SwiftUI
import WidgetKit
import FreeroomsWidgetIntents

struct BuildingWidget: Widget {

  // MARK: Internal

  static let kind: String = "com.devsoc.Freerooms.Widgets.Building"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: Self.kind,
      intent: BuildingConfigurationIntent.self,
      provider: BuildingTimelineProvider(),
      content: _View.init(entry:))
//      content: { _ in EmptyView().containerBackground(.clear, for: .widget) })
      .configurationDisplayName("Building Widget")
      .description("Shows availability information for a building")
      .contentMarginsDisabled()
      .supportedFamilies([.systemMedium, .systemLarge])
      .polyfillPromptsForUserConfiguration()
  }

  // MARK: Private

  private struct _View: View {

    // MARK: Lifecycle

    init(entry: BuildingTimelineProvider.Entry) {
      self.entry = entry
    }

    // MARK: Internal

    let entry: BuildingTimelineProvider.Entry
    let theme = Theme.default

    var body: some View {
      Group {
        switch entry.value {
        case .missingBuilding:
          ContentUnavailableView(
            "No Selected Building",
            systemImage: "building",
            description: Text("Select a building to display"))

        case .failed(let error):
          ContentUnavailableView(
            "Could not load building",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription))

        case .building(let building, let image):
          makeView(for: building, image: image)
        }
      }
      .containerBackground(.clear, for: .widget)
    }

    // MARK: Private

    @Environment(\.widgetContentMargins) private var contentMargins

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
