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
      .supportedFamilies([.systemLarge])
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

    private let theme = Theme.default

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
          VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
              Text(room.name)
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
              Spacer(minLength: 0)
              makeRatingView(forRating: room.overallRating)
                .padding(.bottom, 4)
            }
            #warning("TODO: Replace with building name")
            Label(room.buildingId, systemImage: "building")
              .foregroundStyle(.white)
            HStack {
              AvailabilityIndicator(isAvailable: nil)
              Text("idk")
                .foregroundStyle(.white)
            }
          }
          .padding(Configuration.additionalPadding)
          .padding(contentMargins)
        }
    }

    @ViewBuilder
    private func makeRatingView(forRating rating: Double?) -> some View {
      
      var ratingText: String {
        guard let rating else { return "?.?" }
        return rating.formatted(.number.precision(.fractionLength(1)))
      }

      HStack(spacing: 6) {
        Image(systemName: "star.fill")
        Text(ratingText)
      }
      .font(.caption)
      .foregroundStyle(.white)
      .padding(.vertical, 4)
      .padding(.horizontal, 6)
      .background {
        Capsule()
          .foregroundStyle(
            LinearGradient(
              colors: [
                theme.accent.tertiary,
                theme.accent.primary,
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing))
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
