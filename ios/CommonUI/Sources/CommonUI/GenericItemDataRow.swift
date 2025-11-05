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

public struct HeightPreferenceKey: PreferenceKey {
  public static let defaultValue: CGFloat = 0

  public static func reduce(
    value: inout CGFloat,
    nextValue: () -> CGFloat)
  {
    // Take the maximum height from all child views
    value = max(value, nextValue())
  }
}

// MARK: - HasName

public protocol HasName {
  var name: String { get }
}

// MARK: - HasRating

public protocol HasRating {
  var overallRating: Double? { get }
}

// MARK: - Room + HasName, HasRating

extension Room: HasName, HasRating { }

// MARK: - Building + HasName, HasRating

extension Building: HasName, HasRating { }

// MARK: - GenericItemDataRow

public struct GenericItemDataRow<T: Equatable & Hashable & Identifiable & HasName & HasRating>: View {

  // MARK: Lifecycle

  public init(rowHeight: Binding<CGFloat?>, item: T) {
    _rowHeight = rowHeight
    self.item = item
  }

  // MARK: Public

  public var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 5) {
        Text(item.name)
          .bold()
          .foregroundStyle(theme.label.primary)
          .lineLimit(1)
          .truncationMode(.tail)

        if let room = item as? Room {
          Text(room.statusText)
            .fontWeight(.semibold)
            .foregroundStyle(
              room.status == "free" ? Theme.light.list.green : room.status == "" ? Theme.light.list.gray : Theme
                .light.list.red)
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(
              RoundedRectangle(cornerRadius: 5)
                .fill(
                  room.status == "free" ? Theme.light.list.greenTransparent.opacity(0.15) : room.status == "" ? Theme.light.list
                    .grayTransparent.opacity(0.20) : Theme.light.list.redTransparent.opacity(0.54)))
        } else if let building = item as? Building {
          Text("^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true) available")
        }
      }

      Spacer()
      if let overallRating = item.overallRating {
        Text(overallRating.formatted())
        Image(systemName: "star.fill")
          .foregroundStyle(theme.yellow)
          .padding(.trailing)
      }
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

  @Binding private var rowHeight: CGFloat?

  private let item: T

}

#Preview {
  @Previewable @State var height: CGFloat? = nil

  GenericItemDataRow(
    rowHeight: $height,
    item: Room.exampleOne)
    .defaultTheme()
}
