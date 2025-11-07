//
//  GenericCardViewItem.swift
//  CommonUI
//
//  Created by Gabriella Lianti on 15/10/25.
//

import BuildingModels
import RoomModels
import SwiftUI

// MARK: - WidthPreferenceKey

public struct WidthPreferenceKey: PreferenceKey {
  public static let defaultValue: CGFloat = 0
  public static func reduce(
    value: inout CGFloat,
    nextValue: () -> CGFloat)
  {
    value = max(value, nextValue())
  }
}

// MARK: - GenericCardViewItem

public struct GenericCardViewItem<T: Equatable & Hashable & Identifiable & HasName & HasRating>: View {

  // MARK: Lifecycle

  public init(cardWidth: Binding<CGFloat?>, item: T) {
    _cardWidth = cardWidth
    self.item = item
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: 4) {
      HStack(alignment: .center, spacing: 0) {
        if let room = item as? Room {
          Text(room.abbreviation)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(theme.label.primary)
            .lineLimit(1)
            .truncationMode(.tail)

        } else if let building = item as? Building {
          Text(building.name)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(theme.label.primary)
            .lineLimit(1)
            .truncationMode(.tail)
        }

        Spacer()
        if let overallRating = item.overallRating {
          Text(overallRating.formatted())
            .foregroundStyle(.white)
            .font(.system(size: 12, weight: .semibold))
            .padding(.leading, 2)
          Image(systemName: "star.fill")
            .font(.system(size: 10, weight: .semibold))
            .padding(.trailing)
        } else {
          HStack(spacing: 0) {
            Text("0")
              .foregroundStyle(.white)
              .font(.system(size: 12, weight: .semibold))
              .padding(.leading, 2)
            Image(systemName: "star.fill")
              .font(.system(size: 10, weight: .semibold))
              .foregroundStyle(.white)
          }
          .padding(.horizontal, 4)
          .padding(.vertical, 2)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(theme.label.tertiary))
        }
      }

      HStack(alignment: .center, spacing: 0) {
        if let room = item as? Room {
          Text(room.statusText)
            .font(.system(size: 12, weight: .light))
            .foregroundStyle(
              room.status == "free"
                ? Theme.light.list.green
                : room.status == "" ? Theme.light.list.gray : Theme
                  .light.list.red)
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(
              RoundedRectangle(cornerRadius: 5)
                .fill(
                  room.status == "free"
                    ? Theme.light.list.greenTransparent.opacity(0.15)
                    : room.status == ""
                      ? Theme.light.list
                        .grayTransparent.opacity(0.20)
                      : Theme.light.list.redTransparent.opacity(0.54)))
        } else if let building = item as? Building {
          Text("^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true) available")
        }

        Spacer()
        Image(systemName: "arrow.right")
          .font(.system(size: 16.0, weight: .black))
          .foregroundStyle(theme.label.tertiary)
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(GeometryReader { geometry in
      // In a background the GeometryReader expands to the bounds of the foreground view
      Color.clear.preference(
        key: WidthPreferenceKey.self,
        value: geometry.size.width)
    })
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  @Binding private var cardWidth: CGFloat?

  private let item: T

}

#Preview {
  @Previewable @State var width: CGFloat? = nil

  GenericCardViewItem(
    cardWidth: $width,
    item: Room.exampleOne)
    .defaultTheme()
}
