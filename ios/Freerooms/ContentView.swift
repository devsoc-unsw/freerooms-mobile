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

  @Environment(\.buildingViewModel) var viewModel
  @State var selectedTab = "Buildings"

  var body: some View {
    TabView(selection: $selectedTab) {
      BuildingsTabView(viewModel: viewModel)

      RoomsTabView()
    }
    .tint(theme.accent.primary)
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
}

extension EnvironmentValues {
  @Entry var buildingViewModel: LiveBuildingViewModel = PreviewBuildingViewModel()
}

#Preview {
  ContentView()
    .defaultTheme()
    .environment(\.buildingViewModel, PreviewBuildingViewModel())
}
