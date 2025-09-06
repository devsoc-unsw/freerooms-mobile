//
//  GenericListRowView.swift
//  CommonUI
//
//  Created by Yanlin Li  on 23/8/2025.
//

import BuildingModels
import Combine
import RoomModels
import SwiftUI

// MARK: - GenericListRowView

public struct GenericListRowView<T: Equatable & Identifiable & Hashable & HasName>: View {

  // MARK: Lifecycle

  public init(
    path: Binding<NavigationPath>,
    rowHeight: Binding<CGFloat?>,
    item: T,
    items: [T],
    imageProvider: @escaping (T.ID) -> Image)
  {
    _path = path
    _rowHeight = rowHeight
    self.item = item
    self.items = items
    self.imageProvider = imageProvider
  }

  // MARK: Public

  public var body: some View {
    Button {
      path.append(item)
    } label: {
      HStack(spacing: 0) {
        imageProvider(item.id)
          .resizable()
          .frame(width: rowHeight, height: rowHeight)
          .clipShape(RoundedRectangle(cornerRadius: 5))
          .padding(.trailing)

        GenericItemDataRow<T>(
          rowHeight: $rowHeight,
          item: item)
      }
      .foregroundStyle(theme.label.secondary)
    }
    .listRowBackground(
      RoundedRectangle(cornerRadius: 10)
        .fill(.background)
        .strokeBorder(LinearGradient(
          colors: [
            theme.accent.primary.opacity(1 - Double(items.count - index) / Double(items.count * 2)),
            theme.accent.primary.opacity(1 - Double(items.count - index - 1) / Double(items.count * 2)),
          ],
          startPoint: .top,
          endPoint: .bottom))
        .padding(.top, item == items.first ? 0 : -10) // Hide the top padding on the row unless this is the first row
        .padding(
          .bottom,
          item == items.last ? 0 : -10) // Hide the bottom padding on the row unless this is the last row
    )
    .onPreferenceChange(HeightPreferenceKey.self) {
      rowHeight = $0
    }
  }

  // MARK: Internal

  @Binding var path: NavigationPath
  @Binding var rowHeight: CGFloat?

  let item: T
  let items: [T]
  let imageProvider: (T.ID) -> Image

  var index: Int {
    items.firstIndex(of: item)!
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

}

/// Convenience extensions
extension GenericListRowView where T == Building {
  public init(
    path: Binding<NavigationPath>,
    rowHeight: Binding<CGFloat?>,
    building: Building,
    buildings: [Building],
    imageProvider: @escaping (Building.ID) -> Image)
  {
    _path = path
    _rowHeight = rowHeight
    item = building
    items = buildings
    self.imageProvider = imageProvider
  }
}

extension GenericListRowView where T == Room {
  public init(
    path: Binding<NavigationPath>,
    rowHeight: Binding<CGFloat?>,
    room: Room,
    rooms: [Room],
    imageProvider: @escaping (Room.ID) -> Image)
  {
    _path = path
    _rowHeight = rowHeight
    item = room
    items = rooms
    self.imageProvider = imageProvider
  }
}

// MARK: - PreviewWrapper

struct PreviewWrapper: View {
  @State private var path = NavigationPath()
  @State private var rowHeight: CGFloat?

  let rooms: [Room] = [Room.exampleOne, Room.exampleTwo]

  var body: some View {
    List {
      ForEach(rooms) { room in
        GenericListRowView(
          path: $path,
          rowHeight: $rowHeight,
          room: room,
          rooms: rooms,
          imageProvider: { roomID in
            Image(roomID, bundle: .module)
          })
      }
    }
    .padding()
  }
}

#Preview {
  PreviewWrapper()
    .defaultTheme()
}
