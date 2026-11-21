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

  // MARK: Internal

  @Binding var selectedView: ViewOrientation

  /// Whether rooms can be sorted by distance (needs location permission and a GPS fix).
  let canSortByDistance: Bool

  // A Group, as in the Buildings tab, so each button is its own toolbar item.
  var body: some View {
    Group {
      Button {
        theme.toggleColorScheme(from: colorScheme)
      } label: {
        Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
          .resizable()
          .frame(width: RoomLayoutConstants.toolbarViewToggleIconWidth, height: RoomLayoutConstants.toolbarIconHeight)
      }

      SortMenu(
        options: [.alphabetical, .distance],
        selection: selectedSort,
        isReversed: !roomViewModel.roomsInAscendingOrder,
        canSortByDistance: canSortByDistance,
        onSelect: { roomViewModel.sortOption = $0 == .distance ? .distance : .alphabetical },
        onReverse: { roomViewModel.getRoomsInOrder() })

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
    .foregroundStyle(theme.accent.primary)
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
  @Environment(\.colorScheme) private var colorScheme
  @Environment(LiveRoomViewModel.self) private var roomViewModel

  /// The sort to tick. Alphabetical while there's no location, as that's the order on screen.
  private var selectedSort: SortMenuOption {
    canSortByDistance && roomViewModel.sortOption == .distance ? .distance : .alphabetical
  }

}
