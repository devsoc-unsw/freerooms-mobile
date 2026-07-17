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
  @Environment(TabController.self) var tabController
  @State var selectedRoomsView = ViewOrientation.List
  @State var selectedBuildingsView = ViewOrientation.List

  var body: some View {
    @Bindable var tabController = tabController

    TabView(selection: $tabController.selectedTab) {
      BuildingsTabView(path: $buildingPath, selectedView: $selectedBuildingsView) { building in
        RoomsListView(building: building, path: $buildingPath, imageProvider: {
          BuildingImage[$0]
        })
        .task { await roomViewModel.onAppear() }
        .environment(roomViewModel)
      } _: { room in
        roomDetailsView(for: room)
      }

      MapTabView(
        path: $mapPath,
        mapViewModel: mapViewModel,
        roomImageProvider: { roomID in
          RoomImage[roomID]
        },
        roomDestinationBuilder: { room in
          roomDetailsView(for: room)
        })

      RoomsTabView(
        path: $roomPath,
        selectedTab: $tabController.selectedTab,
        selectedView: $selectedRoomsView)
      { room in
        roomDetailsView(for: room)
      }
    }
    .environment(roomViewModel)
    .environment(buildingViewModel)
    .tint(theme.accent.primary)
  }

  func roomDetailsView(for room: Room) -> some View {
    RoomDetailsView(room: room)
      .environment(roomViewModel)
      .task { await roomViewModel.onAppear() }
      .task {
        roomViewModel.clearRoomBookings()
        await roomViewModel.getRoomBookings(roomId: room.id)
      }
  }

  // MARK: Private

  @State private var buildingPath = NavigationPath()
  @State private var mapPath = NavigationPath()
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
  @Entry var buildingViewModel: LiveBuildingViewModel = LiveBuildingViewModel
    .preview
  @Entry var mapViewModel: LiveMapViewModel = LiveMapViewModel.preview
  @Entry var roomViewModel: LiveRoomViewModel = LiveRoomViewModel.preview
}

#Preview {
  ContentView()
    .defaultTheme()
    .environment(\.buildingViewModel, PreviewBuildingViewModel())
    .environment(
      \.mapViewModel,
      MainActor.assumeIsolated {
        PreviewMapViewModel()
      })
    .environment(\.roomViewModel, PreviewRoomViewModel())
}
