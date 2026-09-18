//
//  RoomWidget.swift
//  Freerooms
//
//  Created by Matthew Yuen on 19/9/2026.
//

import CommonUI
import RoomModels
import SwiftUI
import WidgetKit

struct RoomWidget: Widget {

  // MARK: Internal

  static let kind: String = "com.devsoc.Freerooms.Widgets.Room"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: Self.kind,
      intent: RoomConfigurationIntent.self,
      provider: RoomTimelineProvider(),
      content: _View.init(entry:))
      .configurationDisplayName("Room Widget")
      .description("Shows availability information for a room")
      .contentMarginsDisabled()
      .supportedFamilies([.systemMedium, .systemLarge])
      .polyfillPromptsForUserConfiguration()
  }

  // MARK: Private

  private struct _View: View {

    // MARK: Lifecycle

    init(entry: RoomTimelineProvider.Entry) {
      self.entry = entry
    }

    // MARK: Internal

    let entry: RoomTimelineProvider.Entry

    var body: some View {
      Group {
        switch entry.value {
        case .missingRoom:
          ContentUnavailableView(
            "No Selected Room",
            systemImage: "door.left.hand.open",
            description: Text("Select a room to display"))

        case .failed(let error):
          ContentUnavailableView(
            "Could not load room",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription))

        case .room(let room, image: let image):
          makeView(for: room, image: image)
        }
      }
      .containerBackground(.clear, for: .widget)
    }

    // MARK: Private

    @Environment(\.widgetContentMargins) private var contentMargins
    @Environment(\.widgetFamily) private var family

    @ViewBuilder
    private func makeView(for room: Room, image: Image?) -> some View {
      Color.clear
        .overlay {
          (image ?? Shared.makeFallback(for: family))
            .resizable()
            .scaledToFill()
        }
        .addWidgetGradients()
        .overlay(alignment: .bottom) {
          HStack {
            Text(room.name)
              .font(.title)
              .fontWeight(.medium)
              .foregroundColor(.white)
            Spacer(minLength: 0)
          }
          .padding(Configuration.additionalPadding)
          .padding(contentMargins)
        }
    }

  }
}

#Preview("System Large", as: .systemLarge) {
  RoomWidget()
} timeline: {
  RoomTimelineProvider.Entry.placeholder(family: .systemLarge)
  RoomTimelineProvider.Entry.failed(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError))
  RoomTimelineProvider.Entry.missingRoom
}
