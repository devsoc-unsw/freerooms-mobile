//
//  BuildingWidget.swift
//  Freerooms
//
//  Created by Matthew Yuen on 10/9/2026.
//

import BuildingModels
import BuildingViews
import CommonUI
import RoomViews
import SwiftUI
import WidgetKit

struct BuildingWidget: Widget {

  // MARK: Internal

  static let kind: String = "com.devsoc.Freerooms.Widgets.Building"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: Self.kind,
      intent: BuildingConfigurationIntent.self,
      provider: BuildingTimelineProvider(),
      content: _View.init(entry:))
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

    private static let additionalPadding: CGFloat = 8

    @Environment(\.widgetContentMargins) private var contentMargins
    @Environment(\.widgetFamily) private var family

    private var building: Building {
      guard case .building(let building, _) = entry.value else {
        preconditionFailure("\(#function): Make sure building is available")
      }
      return building
    }

    @ViewBuilder
    private func makeView(for building: Building, image: Image?) -> some View {
      // https://stackoverflow.com/questions/73707062/how-to-scale-an-image-to-fill-the-parent-view-without-affecting-the-layout-in-sw
      Color.clear
        .overlay {
          (image ?? makeFallback())
            .resizable()
            .scaledToFill()
        }
        .overlay {
          LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
        }
        .overlay {
          LinearGradient(colors: [theme.accent.primary.opacity(0.1), .clear], startPoint: .topTrailing, endPoint: .bottomLeading)
        }
        .overlay(alignment: .topLeading) {
          if family == .systemLarge {
            Text("Freerooms")
              .font(.caption)
              .foregroundStyle(.white)
              .opacity(0.25)
              .padding(Self.additionalPadding)
              .padding(contentMargins)
          }
        }
        .clipped()
        .overlay(alignment: .bottom) {
          VStack(alignment: .leading, spacing: 8.0) {
            Text(building.name)
              .frame(maxWidth: .infinity, alignment: .leading)
              .font(.largeTitle.weight(.medium))
              .multilineTextAlignment(.leading)
            HStack(spacing: 8.0) {
              makeActivityIndicator()
              Group {
                if let availableRooms = building.numberOfAvailableRooms {
                  Text("\(availableRooms) rooms available")
                } else {
                  Text("Unknown rooms available")
                }
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          .frame(maxWidth: .infinity)
          .foregroundStyle(.white)
          .padding(Self.additionalPadding)
          .padding(contentMargins)
        }
    }

    private func makeFallback() -> Image {
      let size = CGSize(width: 1024, height: 1024)
      let uiImage = UIImage(named: "default", in: .roomViews, with: nil)!.preparingThumbnail(of: size)!
      return Image(uiImage: uiImage)
    }

    @ViewBuilder
    private func makeActivityIndicator() -> some View {
      var indicatorColor: Color {
        guard let rooms = building.numberOfAvailableRooms else { return .gray }
        return switch rooms {
        case 5...: .green
        case 1..<5: .yellow
        case 0: .red
        default:
          .gray
        }
      }

      let width: CGFloat = 8

      Circle()
        .foregroundStyle(indicatorColor)
        .frame(width: width, height: width)
        .shadow(color: indicatorColor.opacity(0.5), radius: 5)
    }

  }

}

#Preview("System Medium", as: .systemMedium) {
  BuildingWidget()
} timeline: {
  BuildingTimelineProvider.Entry.placeholder
  BuildingTimelineProvider.Entry.failed(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError))
  BuildingTimelineProvider.Entry.missingBuilding
  BuildingTimelineProvider.Entry.building(.init(name: "john", id: "invalid", latitude: 0, longitude: 0, aliases: []))
}

#Preview("System Large", as: .systemLarge) {
  BuildingWidget()
} timeline: {
  BuildingTimelineProvider.Entry.placeholder
  BuildingTimelineProvider.Entry.failed(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError))
  BuildingTimelineProvider.Entry.missingBuilding
  BuildingTimelineProvider.Entry.building(.init(
    name: "john",
    id: "invalid",
    latitude: 0,
    longitude: 0,
    aliases: [],
    numberOfAvailableRooms: 0))
}
