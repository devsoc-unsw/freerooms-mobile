//
//  GenericListRowView.swift
//  CommonUI
//
//  Created by Yanlin Li on 23/8/2025.
//

import BuildingModels
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - GenericListRowView

/// Shared grouped-list row chrome with injectable image and content views.
///
/// The visual container owns sizing, joined borders, selection, and loading behavior. Feature modules
/// provide the content so CommonUI does not need to know about every app model.
public struct GenericListRowView<
  Item: Equatable & Identifiable & Hashable,
  ImageContent: View,
  RowContent: View
>: View {

  // MARK: Lifecycle

  /// Creates a feature-defined row using the common Rooms and Buildings list appearance.
  public init(
    rowHeight: Binding<CGFloat?>,
    item: Item,
    items: [Item],
    isLoading: Bool,
    onSelect: ((Item) -> Void)? = nil,
    imageProvider: @escaping (Item.ID) -> ImageContent,
    @ViewBuilder content: @escaping (Item) -> RowContent)
  {
    _rowHeight = rowHeight
    self.item = item
    self.items = items
    self.isLoading = isLoading
    self.onSelect = onSelect
    self.imageProvider = imageProvider
    rowContent = content
  }

  // MARK: Public

  public var body: some View {
    Group {
      if let onSelect {
        Button {
          onSelect(item)
        } label: {
          rowLabel
        }
        .disabled(isLoading)
      } else {
        rowLabel
          .redacted(reason: isLoading ? .placeholder : [])
      }
    }
    .listRowBackground(rowBackground)
    .onPreferenceChange(HeightPreferenceKey.self) {
      rowHeight = $0
    }
  }

  // MARK: Private

  @Binding private var rowHeight: CGFloat?

  @Environment(Theme.self) private var theme

  private let item: Item
  private let items: [Item]
  private let isLoading: Bool
  private let onSelect: ((Item) -> Void)?
  private let imageProvider: (Item.ID) -> ImageContent
  private let rowContent: (Item) -> RowContent

  private var index: Int {
    items.firstIndex(of: item) ?? items.startIndex
  }

  private var cornerRadii: RectangleCornerRadii {
    RectangleCornerRadii(
      topLeading: item == items.first ? GenericListRowViewLayout.containerCornerRadius : 0,
      bottomLeading: item == items.last ? GenericListRowViewLayout.containerCornerRadius : 0,
      bottomTrailing: item == items.last ? GenericListRowViewLayout.containerCornerRadius : 0,
      topTrailing: item == items.first ? GenericListRowViewLayout.containerCornerRadius : 0)
  }

  private var rowBackground: some View {
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
      .padding(.bottom, item == items.last ? 0 : GenericListRowViewLayout.joinedRowOverlap)
  }

  private var rowLabel: some View {
    HStack(spacing: 0) {
      imageProvider(item.id)
        .aspectRatio(contentMode: .fill)
        .frame(
          width: (rowHeight ?? 0) + GenericListRowViewLayout.imageWidthExtraPadding,
          height: GenericListRowViewLayout.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: GenericListRowViewLayout.imageCornerRadius))
        .padding(.trailing)

      rowContent(item)
        .fixedSize(horizontal: false, vertical: true)
        .background {
          GeometryReader { geometry in
            Color.clear.preference(
              key: HeightPreferenceKey.self,
              value: geometry.size.height)
          }
        }
    }
    .frame(height: (rowHeight ?? 0) + GenericListRowViewLayout.rowHeightExtraPadding)
    .foregroundStyle(theme.label.secondary)
  }

  /// Gradually fades the border down the stacked list so adjacent rows read as one grouped card.
  private func rowGradientOpacity(at gradientIndex: Int) -> Double {
    let itemCount = max(items.count, 1)
    return 1 - Double(itemCount - gradientIndex) / Double(itemCount * 2)
  }
}

// MARK: - Building convenience

extension GenericListRowView where
  Item == Building,
  ImageContent == CachedImage,
  RowContent == GenericItemDataRow<Building>
{
  public init(
    path: Binding<NavigationPath>,
    rowHeight: Binding<CGFloat?>,
    building: Building,
    buildings: [Building],
    isLoading: Bool,
    onSelect: ((Building) -> Void)? = nil,
    imageProvider: @escaping (Building.ID) -> CachedImage)
  {
    self.init(
      rowHeight: rowHeight,
      item: building,
      items: buildings,
      isLoading: isLoading,
      onSelect: onSelect ?? { path.wrappedValue.append($0) },
      imageProvider: imageProvider,
      content: { building in
        GenericItemDataRow(rowHeight: rowHeight, item: building)
      })
  }
}

// MARK: - Room convenience

extension GenericListRowView where
  Item == Room,
  ImageContent == CachedImage,
  RowContent == GenericItemDataRow<Room>
{
  public init(
    path: Binding<NavigationPath>,
    rowHeight: Binding<CGFloat?>,
    room: Room,
    rooms: [Room],
    isLoading: Bool,
    onSelect: ((Room) -> Void)? = nil,
    imageProvider: @escaping (Room.ID) -> CachedImage)
  {
    self.init(
      rowHeight: rowHeight,
      item: room,
      items: rooms,
      isLoading: isLoading,
      onSelect: onSelect ?? { path.wrappedValue.append($0) },
      imageProvider: imageProvider,
      content: { room in
        GenericItemDataRow(rowHeight: rowHeight, item: room)
      })
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

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {

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
