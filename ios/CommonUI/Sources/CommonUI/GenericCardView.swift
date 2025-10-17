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

public struct GenericCardView<T: Equatable & Identifiable & Hashable & HasName & HasRating>: View {

  public init(
    path: Binding<NavigationPath>,
    cardWidth: Binding<CGFloat?>,
    item: T,
    items: [T],
    imageProvider: @escaping (T.ID) -> Image)
  {
    _path = path
    _cardWidth = cardWidth
    self.item = item
    self.items = items
    self.imageProvider = imageProvider
  }

  public var body: some View {
    Button {
      path.append(item)
        // swiftlint:disable:next no_direct_standard_out_logs
        print(item)
        // swiftlint:disable:next no_direct_standard_out_logs
        print("im done haha")
    } label: {
        ZStack(alignment: .top) {
            // TODO: image at the top of the card, rounded corners
            HStack(spacing: 0) {
              GenericCardViewItem<T>(
                cardWidth: $cardWidth,
                item: item)
            }
            .foregroundStyle(theme.label.secondary)
            
            imageProvider(item.id)
              .resizable()
              .frame(width: cardWidth, height: cardWidth) // TODO:
              .clipShape(RoundedRectangle(cornerRadius: 5))
              .padding(.trailing)
        }
    }
    .onPreferenceChange(HeightPreferenceKey.self) {
      cardWidth = $0
    }
  }

  @Binding var path: NavigationPath
  @Binding var cardWidth: CGFloat?

  let item: T
  let items: [T]
  let imageProvider: (T.ID) -> Image

  var index: Int {
    items.firstIndex(of: item)!
  }

  @Environment(Theme.self) private var theme

}

//extension GenericCardView where T == Building {
//  public init(
//    path: Binding<NavigationPath>,
//    cardWidth: Binding<CGFloat?>,
//    building: Building,
//    buildings: [Building],
//    imageProvider: @escaping (Building.ID) -> Image)
//  {
//    _path = path
//    _cardWidth = cardWidth
//    item = building
//    items = buildings
//    self.imageProvider = imageProvider
//  }
//}

extension GenericCardView where T == Room {
  public init(
    path: Binding<NavigationPath>,
    cardWidth: Binding<CGFloat?>,
    room: Room,
    rooms: [Room],
    imageProvider: @escaping (Room.ID) -> Image)
  {
    _path = path
    _cardWidth = cardWidth
    item = room
    items = rooms
    self.imageProvider = imageProvider
  }
}

//struct PreviewWrapper: View {
//  @State private var path = NavigationPath()
//  @State private var cardWidth: CGFloat?
//
//  let rooms: [Room] = [Room.exampleOne, Room.exampleTwo]
//
//  var body: some View {
//    List {
//      ForEach(rooms) { room in
//        GenericCardView(
//          path: $path,
//          cardWidth: $cardWidth,
//          room: room,
//          rooms: rooms,
//          imageProvider: { roomID in
//            Image(roomID, bundle: .module)
//          })
//      }
//    }
//  }
//}
//
//#Preview {
//  PreviewWrapper()
//    .defaultTheme()
//}
