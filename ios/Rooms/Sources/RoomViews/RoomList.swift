//
//  RoomList.swift
//  Rooms
//
//  Created by Nicole Xie on 2026/9/11.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

struct RoomList: View {
  let rooms: [Room]
  let isLoading: Bool

  @Binding var path: NavigationPath
  @Binding var rowHeight: CGFloat?

  var body: some View {
    ForEach(rooms) { room in
      GenericListRowView(
        path: $path,
        rowHeight: $rowHeight,
        room: room,
        rooms: rooms,
        isLoading: isLoading,
        imageProvider: { roomID in
          RoomImage[roomID]
        })
        .padding(.vertical, RoomLayoutConstants.listRowVerticalPadding)
    }
  }
}
