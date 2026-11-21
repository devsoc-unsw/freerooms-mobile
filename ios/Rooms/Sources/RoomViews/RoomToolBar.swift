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

// MARK: - RoomToolBar

struct RoomToolBar: View {

  // MARK: Internal

  @Binding var selectedView: ViewOrientation

  /// Whether rooms can be sorted by distance (needs location permission and a GPS fix).
  let canSortByDistance: Bool

  var body: some View {
    // A Group, as in the Buildings tab, so each button is its own toolbar item.
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
        isReversed: !roomViewModel.sortOptions.isAscending,
        canSortByDistance: canSortByDistance,
        onSelect: { option in
          if let kind = RoomSortOptions.Kind(option) {
            roomViewModel.sort(by: kind)
          }
        },
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
    canSortByDistance ? SortMenuOption(roomViewModel.sortOptions.kind) : .alphabetical
  }

}

// MARK: - Sort menu translation

/// The menu's options are a CommonUI type, so `RoomViewModels` can't name them. This is the one
/// place the two are matched up, as `BuildingsTabView` does for buildings.
extension SortMenuOption {
  fileprivate init(_ kind: RoomSortOptions.Kind) {
    switch kind {
    case .alphabetical: self = .alphabetical
    case .distance: self = .distance
    }
  }
}

extension RoomSortOptions.Kind {
  fileprivate init?(_ option: SortMenuOption) {
    switch option {
    case .alphabetical: self = .alphabetical
    case .distance: self = .distance
    case .availability: return nil
    }
  }
}
