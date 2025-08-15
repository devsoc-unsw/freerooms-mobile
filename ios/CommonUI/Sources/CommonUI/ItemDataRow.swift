//
//  ItemDataRow.swift
//  CommonUI
//
//  Created by Yanlin Li  on 4/8/2025.
//
import BuildingModels
import RoomModels
import SwiftUI

// MARK: - HeightPreferenceKey

private struct HeightPreferenceKey: PreferenceKey {
  static let defaultValue: CGFloat = 0

  static func reduce(
    value _: inout CGFloat,
    nextValue _: () -> CGFloat)
  { }
}

// MARK: - HasName

public protocol HasName {
  var name: String { get }
}

// MARK: - Room + HasName

extension Room: HasName { }

// MARK: - ItemDataRow

struct ItemDataRow<T: Equatable & Hashable & Identifiable & HasName>: View {

  // MARK: Lifecycle

  init(rowHeight: Binding<CGFloat?>, item: T) {
    _rowHeight = rowHeight
    self.item = item
  }

  // MARK: Internal

  @Binding var rowHeight: CGFloat?

  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading) {
        Text(item.name)
          .bold()
          .foregroundStyle(theme.label.primary)
          .lineLimit(1)
          .truncationMode(.tail)

        if let room = item as? Room {
          let isAvailable = true
          Text("\(isAvailable ? "Available" : "Unavailable")")
            .foregroundStyle(isAvailable ? .green : .red)
        } else if let building = item as? Building {
          // The `^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true)` handles plurals using "automatic grammar agreement", works for a couple languages
          Text("^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true) available")
        }
      }

      Spacer()

      Text("4.9")
      Image(systemName: "star.fill")
        .foregroundStyle(theme.yellow)
        .padding(.trailing)

      Image(systemName: "chevron.right")
    }
    .background(GeometryReader { geometry in
      // In a background the GeometryReader expands to the bounds of the foreground view
      Color.clear.preference(
        key: HeightPreferenceKey.self, // This saves the height into the HeightPreferenceKey
        value: geometry.size.height)
    })
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private let item: T

}

#Preview {
  @Previewable @State var height: CGFloat? = nil

  ItemDataRow(
    rowHeight: $height,
    item: Room(name: "Room 101", id: "K-101", abbreviation: "T-101", capacity: 20, usage: "Classroom", school: "UNSW"))
    .defaultTheme()
}
