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
        Text(item.name)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(.black)
          .lineLimit(1)
          .truncationMode(.tail)

        Spacer()
        // TODO: rating colors
        if let overallRating = item.overallRating {
          Text(overallRating.formatted())
          Image(systemName: "star.fill")
            .foregroundStyle(theme.yellow)
            .padding(.trailing)
        } else {
          HStack(spacing: 4) {
            Text("0")
              .foregroundStyle(.white)
              .padding(.leading, 2)
            Image(systemName: "star.fill")
              .foregroundStyle(.white)
          }
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(
            RoundedRectangle(cornerRadius: 10)
              .fill(theme.label.tertiary))
        }
      }

      HStack(alignment: .center, spacing: 0) {
        // TODO: hex codes?, unavailable till \(time)
        if let room = item as? Room {
          Text("\(room.status == "free" ? "Available till" : room.status == "" ? "status not available" : "Unavailable till")")
            .foregroundStyle(room.status == "free" ? .green : room.status == "" ? .gray : .red)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
              RoundedRectangle(cornerRadius: 8)
                .fill(
                  room.status == "free" ? .green.opacity(0.18) : room.status == "" ? .gray.opacity(0.18) : .red.opacity(0.18)))
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
