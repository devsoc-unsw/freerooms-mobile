//
//  ContentView.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import BuildingViewModels
import BuildingViews
import CommonUI
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

  var body: some View {
    TabView(selection: $selectedTab) {
      BuildingsTabView(path: $path, viewModel: buildingViewModel) { building in
        RoomsListView(roomViewModel: roomViewModel, building: building, path: $path, imageProvider: {
          BuildingImage[$0]
        })
        .onAppear(perform: roomViewModel.onAppear)
      }
      MapTabView(mapViewModel: mapViewModel)
      RoomsTabView(roomViewModel: roomViewModel, buildingViewModel: buildingViewModel, selectedTab: $selectedTab)
    }
    .tint(theme.accent.primary)
  }

  // MARK: Private

  @State private var path = NavigationPath()

  @Environment(Theme.self) private var theme
}

extension EnvironmentValues {
  @Entry var buildingViewModel: LiveBuildingViewModel = PreviewBuildingViewModel()
  @Entry var mapViewModel: LiveMapViewModel = MainActor.assumeIsolated {
    PreviewMapViewModel()
  }

  @Entry var roomViewModel: LiveRoomViewModel = PreviewRoomViewModel()
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
