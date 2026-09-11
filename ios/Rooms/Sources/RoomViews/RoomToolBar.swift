//
//  RoomToolBar.swift
//  Rooms
//
//  Created by Nicole Xie on 2026/9/11.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

struct RoomToolBar: View {
  @Binding var selectedView: ViewOrientation
  
  @Environment(Theme.self) private var theme
  @Environment(\.colorScheme) private var colorScheme
  @Environment(LiveRoomViewModel.self) private var roomViewModel
  
  var body: some View {
    HStack {
      Button {
        theme.toggleColorScheme(from: colorScheme)
      } label: {
        Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
          .resizable()
          .frame(width: RoomLayoutConstants.toolbarViewToggleIconWidth, height: RoomLayoutConstants.toolbarIconHeight)
      }

      Button {
        roomViewModel.getRoomsInOrder()
      } label: {
        Image(systemName: "arrow.up.arrow.down")
          .resizable()
          .frame(width: RoomLayoutConstants.toolbarSortIconWidth, height: RoomLayoutConstants.toolbarIconHeight)
      }

      Button {
        if selectedView == ViewOrientation.Card {
          selectedView = ViewOrientation.List
        } else {
          selectedView = ViewOrientation.Card
        }
      } label: {
        Image(systemName: selectedView == ViewOrientation.List ? "square.grid.2x2" : "list.bullet")
          .resizable()
          .frame(width: RoomLayoutConstants.toolbarViewToggleIconWidth, height: RoomLayoutConstants.toolbarIconHeight)
      }
    }
    .padding(RoomLayoutConstants.toolbarIconPadding)
    .foregroundStyle(theme.accent.primary)
  }
}
