//
//  GenericListRowView.swift
//  CommonUI
//
//  Created by Yanlin Li  on 23/8/2025.
//

import BuildingModels
import Combine
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - GenericListRowView

public struct GenericListRowView<T: Equatable & Identifiable & Hashable & HasName & HasRating, ImageContent: View>: View {

  // MARK: Lifecycle

  public init(
    path: Binding<NavigationPath>,
    rowHeight: Binding<CGFloat?>,
    item: T,
    items: [T],
    isLoading: Bool,
    onSelect: ((T) -> Void)? = nil,
    imageProvider: @escaping (T.ID) -> ImageContent)
  {
    _path = path
    _rowHeight = rowHeight
    self.item = item
    self.items = items
    self.isLoading = isLoading
    self.onSelect = onSelect
    self.imageProvider = imageProvider
  }

  // MARK: Public

  public var body: some View {
    Button {
      if let onSelect {
        onSelect(item)
      } else {
        path.append(item)
      }
    } label: {
      HStack(spacing: 0) {
        imageProvider(item.id)
          .aspectRatio(contentMode: .fill)
          .frame(
            width: (rowHeight ?? 0) + GenericListRowViewLayout.imageWidthExtraPadding,
            height: GenericListRowViewLayout.imageHeight)
          .clipShape(RoundedRectangle(cornerRadius: GenericListRowViewLayout.imageCornerRadius))
          .padding(.trailing)

        GenericItemDataRow<T>(
          rowHeight: $rowHeight,
          item: item)
      }
      .frame(height: (rowHeight ?? 0) + GenericListRowViewLayout.rowHeightExtraPadding)
      .foregroundStyle(theme.label.secondary)
    }
    .disabled(isLoading)
    .listRowBackground(
      UnevenRoundedRectangle(cornerRadii: cornerRadii)
        .fill(theme.background.secondary)
        .strokeBorder(LinearGradient(
          colors: [
            theme.accent.primary.opacity(rowGradientOpacity(at: index)),
            theme.accent.primary.opacity(rowGradientOpacity(at: index + 1)),
          ],
          startPoint: .top,
          endPoint: .bottom))
        .padding(.top, item == items.first ? 0 : GenericListRowViewLayout.joinedRowOverlap)
        .padding(
          .bottom,
          item == items.last ? 0 : GenericListRowViewLayout.joinedRowOverlap))
    .onPreferenceChange(HeightPreferenceKey.self) {
      rowHeight = $0
    }
  }

  // MARK: Internal

  @Binding var path: NavigationPath
  @Binding var rowHeight: CGFloat?

  let item: T
  let items: [T]
  let isLoading: Bool
  let onSelect: ((T) -> Void)?
  let imageProvider: (T.ID) -> ImageContent

  var cornerRadii: RectangleCornerRadii {
    RectangleCornerRadii(
      topLeading: item == items.first ? GenericListRowViewLayout.containerCornerRadius : 0,
      bottomLeading: item == items.last ? GenericListRowViewLayout.containerCornerRadius : 0,
      bottomTrailing: item == items.last ? GenericListRowViewLayout.containerCornerRadius : 0,
      topTrailing: item == items.first ? GenericListRowViewLayout.containerCornerRadius : 0)
  }

  var index: Int {
    items.firstIndex(of: item)!
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  /// Gradually fades the border down the stacked list so adjacent rows read as one grouped card.
  private func rowGradientOpacity(at gradientIndex: Int) -> Double {
    1 - Double(items.count - gradientIndex) / Double(items.count * 2)
  }

}

// MARK: - GenericListRowViewLayout

private enum GenericListRowViewLayout {
  static let containerCornerRadius: CGFloat = 30
  static let imageCornerRadius: CGFloat = 5
  static let imageHeight: CGFloat = 60
  static let imageWidthExtraPadding: CGFloat = 40

  /// Negative padding lets adjacent rows overlap so the grouped card border appears continuous.
  static let joinedRowOverlap: CGFloat = -10
  static let rowHeightExtraPadding: CGFloat = 15
}

/// Convenience extensions
extension GenericListRowView where T == Building, ImageContent == CachedImage {
  public init(
    path: Binding<NavigationPath>,
    rowHeight: Binding<CGFloat?>,
    building: Building,
    buildings: [Building],
    isLoading: Bool,
    onSelect: ((Building) -> Void)? = nil,
    imageProvider: @escaping (Building.ID) -> CachedImage)
  {
    _path = path
    _rowHeight = rowHeight
    item = building
    items = buildings
    self.isLoading = isLoading
    self.onSelect = onSelect
    self.imageProvider = imageProvider
  }
}

extension GenericListRowView where T == Room, ImageContent == CachedImage {
  public init(
    path: Binding<NavigationPath>,
    rowHeight: Binding<CGFloat?>,
    room: Room,
    rooms: [Room],
    isLoading: Bool,
    onSelect: ((Room) -> Void)? = nil,
    imageProvider: @escaping (Room.ID) -> CachedImage)
  {
    _path = path
    _rowHeight = rowHeight
    item = room
    items = rooms
    self.isLoading = isLoading
    self.onSelect = onSelect
    self.imageProvider = imageProvider
  }
}

// MARK: - PreviewWrapper

struct PreviewWrapper: View {

  // MARK: Internal

  let rooms: [Room] = [Room.exampleOne, Room.exampleTwo]

  var body: some View {
    List {
      ForEach(rooms) { room in
        GenericListRowView(
          path: $path,
          rowHeight: $rowHeight,
          room: room,
          rooms: rooms,
          isLoading: false,
          imageProvider: { roomID in
            CachedImage(name: roomID, bundle: .module)
          })
      }
    }
  }

  // MARK: Private

  @State private var path = NavigationPath()
  @State private var rowHeight: CGFloat?

}

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return PreviewWrapper()
    .defaultTheme()
    .environment(viewModel)
}
