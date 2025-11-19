//
//  GenericCardView.swift
//  CommonUI
//
//  Created by Gabriella Lianti on 15/10/25.
//

import BuildingModels
import Combine
import RoomModels
import SwiftUI

// MARK: - GenericCardView

public struct GenericCardView<T: Equatable & Identifiable & Hashable & HasName & HasRating>: View {

  // MARK: Lifecycle

  public init(
    path: Binding<NavigationPath>,
    cardWidth: Binding<CGFloat?>,
    item: T,
    items: [T],
    isLoading: Bool,
    imageProvider: @escaping (T.ID) -> Image)
  {
    _path = path
    _cardWidth = cardWidth
    self.item = item
    self.items = items
    self.imageProvider = imageProvider
    self.isLoading = isLoading
  }

  // MARK: Public

  public var body: some View {
    Button {
      path.append(item)
    } label: {
      VStack(spacing: 0) {
        imageProvider(item.id)
          .resizable()
          .scaledToFill()
          .frame(width: cardWidth, height: 116)
          .clipped()
          .clipShape(
            UnevenRoundedRectangle(
              topLeadingRadius: 22,
              bottomLeadingRadius: 0,
              bottomTrailingRadius: 0,
              topTrailingRadius: 22))

        GenericCardViewItem<T>(
          cardWidth: $cardWidth,
          item: item)

        Spacer()
      }
      .frame(width: cardWidth, height: 173)
      .background(.white)
      .clipShape(RoundedRectangle(cornerRadius: 22))
      .padding(0)
      .buttonStyle(.plain)
      .onPreferenceChange(WidthPreferenceKey.self) {
        cardWidth = $0
      }
      .disabled(isLoading)
    }
  }

  // MARK: Internal

  @Binding var path: NavigationPath
  @Binding var cardWidth: CGFloat?

  let item: T
  let items: [T]
  let imageProvider: (T.ID) -> Image
  let isLoading: Bool

  var index: Int {
    items.firstIndex(of: item)!
  }

}

extension GenericCardView where T == Building {
  public init(
    path: Binding<NavigationPath>,
    cardWidth: Binding<CGFloat?>,
    building: Building,
    buildings: [Building],
    isLoading: Bool,
    imageProvider: @escaping (Building.ID) -> Image)
  {
    _path = path
    _cardWidth = cardWidth
    item = building
    items = buildings
    self.imageProvider = imageProvider
    self.isLoading = isLoading
  }
}

extension GenericCardView where T == Room {
  public init(
    path: Binding<NavigationPath>,
    cardWidth: Binding<CGFloat?>,
    room: Room,
    rooms: [Room],
    isLoading: Bool,
    imageProvider: @escaping (Room.ID) -> Image)
  {
    _path = path
    _cardWidth = cardWidth
    item = room
    items = rooms
    self.imageProvider = imageProvider
    self.isLoading = isLoading
  }
}

// MARK: - CardPreviewWrapper

struct CardPreviewWrapper: View {
  @State private var path = NavigationPath()
  @State private var cardWidth: CGFloat?

  let rooms: [Room] = [Room.exampleOne, Room.exampleTwo]

  var body: some View {
    LazyVGrid(columns: columns) {
      ForEach(rooms) { room in
        GenericCardView(
          path: $path,
          cardWidth: $cardWidth,
          room: room,
          rooms: rooms,
          isLoading: true,
          imageProvider: { roomID in
            Image(roomID, bundle: .module)
          })
      }
    }
  }
}

private let columns = [
  GridItem(.flexible(), spacing: 10),
  GridItem(.flexible()),
]

#Preview {
  CardPreviewWrapper()
    .defaultTheme()
}
