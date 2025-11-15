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
  @Environment(\.mapViewModel) var mapViewModel
  @Environment(\.roomViewModel) var roomViewModel
  @State var selectedTab = "Buildings"
  @State var selectedView = RoomOrientation.List

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
      MapTabView(mapViewModel: mapViewModel)
      RoomsTabView(
        path: $roomPath,
        roomViewModel: roomViewModel,
        buildingViewModel: buildingViewModel,
        selectedTab: $selectedTab,
        selectedView: $selectedView)
      { room in
        RoomDetailsView(room: room, roomViewModel: roomViewModel)
          .task { await roomViewModel.onAppear() }
          .task {
            roomViewModel.clearRoomBookings()
            await roomViewModel.getRoomBookings(roomId: room.id)
          }
      }
    }
    .tint(theme.accent.primary)
  }

  // MARK: Private

  @State private var buildingPath = NavigationPath()
  @State private var roomPath = NavigationPath()

  @Environment(Theme.self) private var theme
}

extension LiveBuildingViewModel {
  static let preview = PreviewBuildingViewModel()
}

extension LiveRoomViewModel {
  static let preview = PreviewRoomViewModel()
}

extension LiveMapViewModel {
  static let preview = PreviewMapViewModel()
}

extension EnvironmentValues {
  @Entry var buildingViewModel: LiveBuildingViewModel = LiveBuildingViewModel.preview
  @Entry var mapViewModel: LiveMapViewModel = LiveMapViewModel.preview
  @Entry var roomViewModel: LiveRoomViewModel = LiveRoomViewModel.preview
}

#Preview {
  ContentView()
    .defaultTheme()
    .environment(\.buildingViewModel, PreviewBuildingViewModel())
    .environment(\.mapViewModel, MainActor.assumeIsolated {
      PreviewMapViewModel()
    })
    .environment(\.roomViewModel, PreviewRoomViewModel())
}
