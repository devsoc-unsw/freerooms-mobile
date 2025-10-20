//
//  ContentView.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import BuildingModels
import BuildingViewModels
import BuildingViews
import CommonUI
import RoomModels
import RoomViewModels
import RoomViews
import SwiftUI

// MARK: - ContentView

/// No logic, only UI
struct ContentView: View {

  // MARK: Internal

  @Environment(\.buildingViewModel) var buildingViewModel
  @Environment(\.roomViewModel) var roomViewModel
  @State var selectedTab = "Buildings"

  var body: some View {
    TabView(selection: $selectedTab) {
      BuildingsTabView(path: $buildingPath, viewModel: buildingViewModel) { building in
        RoomsListView(roomViewModel: roomViewModel, building: building, path: $buildingPath, imageProvider: {
          BuildingImage[$0]
        })
        .task { await roomViewModel.onAppear() }
      } _: { room in
        RoomDetailsView(room: room, roomViewModel: roomViewModel)
          .task {
            await roomViewModel.onAppear()
          }
          .task {
            roomViewModel.clearRoomBookings()
            await roomViewModel.getRoomBookings(roomId: room.id)
          }
      }

      RoomsTabView(
        path: $roomPath,
        roomViewModel: roomViewModel,
        buildingViewModel: buildingViewModel,
        selectedTab: $selectedTab)
      { room in
        RoomDetailsView(room: room, roomViewModel: roomViewModel)
          .task { await roomViewModel.onAppear() }
          .task {
            roomViewModel.clearRoomBookings()
            await roomViewModel.getRoomBookings(roomId: room.id)
          }
      }
      
//      RoomsTabView(
//        path: $roomPath,
//        roomViewModel: roomViewModel,
//        buildingViewModel: buildingViewModel,
//        selectedTab: $selectedTab)
//      { room in
//        RoomDetailsView(room: room, roomViewModel: roomViewModel)
//          .task { await roomViewModel.onAppear() }
//          .task {
//            roomViewModel.clearRoomBookings()
//            await roomViewModel.getRoomBookings(roomId: room.id)
//          }
//      }
    }
    .tint(theme.accent.primary)
  }

  // MARK: Private

  @State private var buildingPath = NavigationPath()
  @State private var roomPath = NavigationPath()

  @Environment(Theme.self) private var theme
}

extension EnvironmentValues {
  @Entry var buildingViewModel: LiveBuildingViewModel = PreviewBuildingViewModel()
  @Entry var roomViewModel: LiveRoomViewModel = PreviewRoomViewModel()
}

#Preview {
  ContentView()
    .defaultTheme()
    .environment(\.buildingViewModel, PreviewBuildingViewModel())
    .environment(\.roomViewModel, PreviewRoomViewModel())
}
