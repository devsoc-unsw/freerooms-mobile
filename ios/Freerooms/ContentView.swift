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
      BuildingsTabView(path: $path, viewModel: buildingViewModel) { building in
        RoomsListView(roomViewModel: roomViewModel, building: building, path: $path, imageProvider: {
          BuildingImage[$0]
        })
        .onAppear(perform: roomViewModel.onAppear)
      }

      RoomsTabView(roomViewModel: roomViewModel, buildingViewModel: buildingViewModel, selectedTab: $selectedTab)
    }
    .tint(theme.accent.primary)
  }

  // MARK: Private

  @State private var path = NavigationPath()

  @Environment(Theme.self) private var theme
}

extension EnvironmentValues {
  @Entry var buildingViewModel: BuildingViewModel = FakeBuildingViewModel()
  @Entry var roomViewModel: RoomViewModel = FakeRoomViewModel()
}

#Preview {
  ContentView()
    .defaultTheme()
    .environment(\.buildingViewModel, PreviewBuildingViewModel())
    .environment(\.roomViewModel, PreviewRoomViewModel())
}

// MARK: - FakeBuildingViewModel

struct FakeBuildingViewModel: BuildingViewModel {

  // MARK: Lifecycle

  nonisolated init() {
    buildings = ([], [], [])
    filteredBuildings = ([], [], [])
    allBuildings = []
    buildingsInAscendingOrder = false
    isLoading = false
    hasLoaded = false
    searchText = ""
  }

  // MARK: Internal

  var buildings: BuildingModels.CampusBuildings
  var filteredBuildings: BuildingModels.CampusBuildings
  var allBuildings: [BuildingModels.Building]
  var buildingsInAscendingOrder: Bool
  var isLoading: Bool
  var hasLoaded: Bool
  var searchText: String

  func getBuildingsInOrder() { }
  func onAppear() { }
}

// MARK: - FakeRoomViewModel

struct FakeRoomViewModel: RoomViewModel {

  // MARK: Lifecycle

  nonisolated init() {
    rooms = []
    roomsByBuildingId = [:]
    roomsInAscendingOrder = false
    isLoading = false
    hasLoaded = false
  }

  // MARK: Internal

  var rooms: [RoomModels.Room]
  var roomsByBuildingId: [String: [RoomModels.Room]]
  var roomsInAscendingOrder: Bool
  var isLoading: Bool
  var hasLoaded: Bool

  func getRoomsInOrder() { }
  func onAppear() { }
}
