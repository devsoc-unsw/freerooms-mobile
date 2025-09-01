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
  @Environment(\.roomViewModel) var roomViewModel
  @State var selectedTab = "Buildings"

  var body: some View {
    TabView(selection: $selectedTab) {
      BuildingsTabView(viewModel: buildingViewModel)

      RoomsTabView(viewModel: roomViewModel)
    }
    .tint(theme.accent.primary)
  }

  // MARK: Private

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
