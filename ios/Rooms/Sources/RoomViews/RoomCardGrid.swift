//
//  RoomCardGrid.swift
//  Rooms
//
//  Created by Nicole Xie on 2026/9/11.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

struct RoomCardGrid: View {

  // MARK: Internal

  let rooms: [Room]
  let isLoading: Bool

  @Binding var path: NavigationPath
  @Binding var cardWidth: CGFloat?

  var body: some View {
    LazyVGrid(columns: columns, spacing: RoomLayoutConstants.cardGridSpacing) {
      ForEach(rooms) { room in
        GenericCardView(
          path: $path,
          cardWidth: $cardWidth,
          room: room,
          rooms: rooms,
          isLoading: roomViewModel.isLoading,
          // GenericCardView expects a binding, while favorites use a toggle API.
          isFavourite: Binding(
            get: {
              roomViewModel.isFavorite(roomID: room.id)
            },
            set: { _ in
              roomViewModel.toggleFavorite(roomID: room.id)
            }),
          imageProvider: { roomID in
            RoomImage[roomID]
          })
      }
    }
    .padding(.horizontal, RoomLayoutConstants.contentHorizontalPadding)
  }

  // MARK: Private

  @Environment(LiveRoomViewModel.self) private var roomViewModel

  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

}
