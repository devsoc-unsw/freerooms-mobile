//
//  GenericRowView.swift
//  CommonUI
//
//  Created by Yanlin Li  on 4/8/2025.
//
import RoomModels
import SwiftUI

// MARK: - GenericListRowView

public struct GenericListRowView<T: Equatable & Hashable & Identifiable & HasName>: View {

  // MARK: Lifecycle

  public init(
    path: Binding<NavigationPath>,
    rowHeight: Binding<CGFloat?>,
    item: T,
    items: [T],
    bundle: Bundle)
  {
    _path = path
    _rowHeight = rowHeight
    self.item = item
    self.items = items
    self.bundle = bundle
  }

  // MARK: Public

  public var body: some View {
    Button {
      path.append(item)
    } label: {
      HStack(spacing: 0) {
        ItemImage[item.id as! String, bundle]
          .resizable()
          .frame(width: rowHeight, height: rowHeight) // This image matches the height of the below HStack
          .clipShape(RoundedRectangle(cornerRadius: 5))
          .padding(.trailing)

        ItemDataRow<T>(
          rowHeight: $rowHeight,
          item: item)
      }
      .foregroundStyle(theme.label.secondary) // Applies to everything in child views unless overridden
    }
    .onPreferenceChange(HeightPreferenceKey.self) {
      rowHeight = $0 // This value comes from the HStack above
    }
  }

  // MARK: Internal

  @Binding var path: NavigationPath
  @Binding var rowHeight: CGFloat?

  let item: T
  let items: [T]
  let bundle: Bundle

  var index: Int {
    items.firstIndex(of: item)!
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

}

// MARK: - UnifiedBorderContainer

struct UnifiedBorderContainer: ViewModifier {

  // MARK: Internal

  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: 10)
          .fill(.background)
          .strokeBorder(LinearGradient(
            colors: [
              theme.accent.primary.opacity(0.8),
              theme.accent.primary.opacity(0.4),
            ],
            startPoint: .top,
            endPoint: .bottom)))
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

}

extension View {
  func unifiedBorder() -> some View {
    modifier(UnifiedBorderContainer())
  }
}

// MARK: - HeightPreferenceKey

private struct HeightPreferenceKey: PreferenceKey {
  static let defaultValue: CGFloat = 0

  static func reduce(
    value _: inout CGFloat,
    nextValue _: () -> CGFloat)
  { }
}

// MARK: - PreviewWrapper

struct PreviewWrapper: View {
  @State private var path = NavigationPath()
  @State private var rowHeight: CGFloat?

  let rooms: [Room] = [
    Room(name: "Ainsworth 101", id: "K-B16", abbreviation: "A-101", capacity: 10, usage: "Goon", school: "UNSW"),
    Room(name: "Ainsworth 201", id: "K-B17", abbreviation: "A-201", capacity: 10, usage: "Goon", school: "UNSW"),
  ]

  var body: some View {
    VStack(spacing: 0) {
      ForEach(rooms) { room in
        GenericListRowView<Room>(
          path: $path,
          rowHeight: $rowHeight,
          item: room,
          items: rooms,
          bundle: .module)
          .padding(.horizontal)
          .padding(.vertical, 5)
      }
    }
    .unifiedBorder()
    .padding()
  }
}

#Preview {
  PreviewWrapper()
    .defaultTheme()
}
