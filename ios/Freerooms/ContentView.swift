//
//  ContentView.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import BuildingViewModels
import BuildingViews
import CommonUI
import RoomViews
import SwiftUI

// MARK: - ContentView

/// No logic, only UI
struct ContentView: View {

  // MARK: Internal

  @Environment(\.buildingViewModel) var buildingViewModel
  @Environment(\.mapViewModel) var mapViewModel
  @State var selectedTab = "Buildings"

  var body: some View {
    TabView(selection: $selectedTab) {
      BuildingsTabView(viewModel: buildingViewModel)
      MapTabView(mapViewModel: mapViewModel)
      RoomsTabView()
    }
    .tint(theme.accent.primary)
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
}

extension EnvironmentValues {
  @Entry var buildingViewModel: LiveBuildingViewModel = PreviewBuildingViewModel()
  @Entry var mapViewModel: LiveMapViewModel = MainActor.assumeIsolated {
    PreviewMapViewModel()
  }
}

#Preview {
  ContentView()
    .defaultTheme()
    .environment(\.buildingViewModel, PreviewBuildingViewModel())
    .environment(\.mapViewModel, MainActor.assumeIsolated {
      PreviewMapViewModel()
    })
}
