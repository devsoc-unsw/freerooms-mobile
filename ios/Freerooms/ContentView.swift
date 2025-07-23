//
//  ContentView.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import Buildings
import BuildingViews
import CommonUI
import Rooms
import RoomViews
import SwiftUI
//import Location

// MARK: - ContentView

/// No logic, only UI
struct ContentView: View {

  // MARK: Internal

  var viewModel: BuildingViewModel
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

#Preview {
  ContentView(viewModel: PreviewBuildingViewModel())
    .defaultTheme()
}
