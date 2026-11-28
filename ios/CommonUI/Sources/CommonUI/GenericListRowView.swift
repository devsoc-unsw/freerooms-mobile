//
//  GenericListRowView.swift
//  CommonUI
//
//  Created by Yanlin Li on 23/8/2025.
//

public import BuildingModels
public import RoomModels
import RoomViewModels
public import SwiftUI

/// Declares where the item to present is within the collection
///
/// This is by ``GenericListRowView`` to decide how to draw border items
internal enum GenericListRowItemLocation: Sendable {
  case middle
  case top
  case bottom
  case onlyItem
  
  /// Get the placement for the provided item
  ///
  /// > Precondition:
  /// > `item` is contained with `collection`.
  ///
  /// - Parameters:
  ///   - item: The item to display
  ///   - collection: The collection containing `item`
  ///
  /// - Returns:
  ///   The location for the provided item
  public static func from<Item: Equatable>(
    item: Item,
    in collection: [Item]
  ) -> Self {
    assert(collection.count >= 1, "Collection detected to be empty, so does not contain the item")
    
    // If there is only one list item
    if collection.count == 1 {
      assert(collection.first == item, "Collection contains one element, but does not contain item")
      return .onlyItem
    }

    if collection.first == item {
      return .top
    }
    
    if collection.last == item {
      return .bottom
    }
    
    return .middle
  }
  
  /// Gets the placement for the provided index, relative to the total amount of items
  ///
  /// > Precondition:
  /// > `index < itemCount, index >= 0`
  ///
  /// - Parameters:
  ///   - index: The index of the item
  ///   - itemCount: The total amount of items
  ///
  /// - Returns:
  ///   The location for the provided `index`, relative to `itemCount`
  public static func from(
    index: Int,
    itemCount: Int
  ) -> Self {
    assert(index < itemCount, "Index is greater than item count")
    assert(index >= 0, "Index is negative")
    
    if itemCount == 1 {
      return .onlyItem
    }
    
    if index == 0 {
      return .top
    }
    
    if (index + 1) == itemCount {
      return .bottom
    }
    
    return .middle
  }
  
}

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
  @available(*, deprecated, renamed: "init(rowHeight:item:itemCount:isLoading:onSelect:imageProvider:content:)", message: "Prefer using the new initializer, which runs in O(1) instead of O(n).")
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
    self.index = items.firstIndex(of: item)!
    self.itemCount = items.count
    self.isLoading = isLoading
    self.onSelect = onSelect
    self.imageProvider = imageProvider
    rowContent = content
  }
  
  /// Creates a feature-defined row using the common Rooms and Buildings list appearance.
  ///
  /// - Parameters:
  ///   - rowHeight: A `Binding` providing the height of each row. Use this property to ensure `rowHeight`s are the same for all list items
  ///   - item: The item to show
  ///   - index: The `index` of `item` within the source collection
  ///   - itemCount: The total amount of items
  ///   - isLoading: Whether the content is loading
  ///   - onSelect: A callback called when the item is selected
  ///   - imageProvider: The image provider
  ///   - content: The content to show within the list item
  ///
  /// > Precondition:
  /// > `index < itemCount && index >= 0`
  public init(
    rowHeight: Binding<CGFloat?>,
    item: Item,
    index: Int,
    itemCount: Int,
    isLoading: Bool,
    onSelect: ((Item) -> Void)? = nil,
    imageProvider: @escaping (Item.ID) -> ImageContent,
    @ViewBuilder content: @escaping (Item) -> RowContent)
  {
    _rowHeight = rowHeight
    self.item = item
    self.index = index
    self.itemCount = itemCount
    self.isLoading = isLoading
    self.onSelect = onSelect
    self.imageProvider = imageProvider
    self.rowContent = content
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
  private let index: Int
  private let itemCount: Int
  private let isLoading: Bool
  private let onSelect: ((Item) -> Void)?
  private let imageProvider: (Item.ID) -> ImageContent
  private let rowContent: (Item) -> RowContent
  
  private var itemLocation: GenericListRowItemLocation {
    GenericListRowItemLocation.from(index: index, itemCount: itemCount)
  }

  private var cornerRadii: RectangleCornerRadii {
    RectangleCornerRadii(
      topLeading: itemLocation == .top ? GenericListRowViewLayout.containerCornerRadius : 0,
      bottomLeading: itemLocation == .bottom ? GenericListRowViewLayout.containerCornerRadius : 0,
      bottomTrailing: itemLocation == .bottom ? GenericListRowViewLayout.containerCornerRadius : 0,
      topTrailing: itemLocation == .top ? GenericListRowViewLayout.containerCornerRadius : 0)
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
      .padding(.top, itemLocation == .top ? 0 : GenericListRowViewLayout.joinedRowOverlap)
      .padding(.bottom, itemLocation == .bottom ? 0 : GenericListRowViewLayout.joinedRowOverlap)
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
    let itemCount = max(itemCount, 1)
    return 1 - Double(itemCount - gradientIndex) / Double(itemCount * 2)
  }
}

// MARK: - Building convenience

extension GenericListRowView where
  Item == Building,
  ImageContent == CachedImage,
  RowContent == GenericItemDataRow<Building>
{
  @available(*, deprecated, renamed: "init(rowHeight:item:itemCount:isLoading:onSelect:imageProvider:content:)", message: "Prefer using the new initializer, which runs in O(1) instead of O(n).")
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
  @available(*, deprecated, renamed: "init(rowHeight:item:itemCount:isLoading:onSelect:imageProvider:content:)", message: "Prefer using the new initializer, which runs in O(1) instead of O(n).")
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

/*

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return PreviewWrapper()
    .defaultTheme()
    .environment(viewModel)
}
 
 */
