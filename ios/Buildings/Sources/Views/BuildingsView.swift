//
//  BuildingsView.swift
//  Buildings
//
//  Created by Yanlin Li  on 4/7/2025.
//

import Buildings
import CommonUI
import SwiftUI

struct BuildingsView: View {

  @State var viewModel: BuildingViewModel
  @State var selectedTab = "Buildings"

  var body: some View {
    TabView(selection: $selectedTab) {
      BuildingsTabView(viewModel: viewModel)

      RoomsTabView()
    }
    .tint(theme.accent.primary)
  }

  @Environment(Theme.self) private var theme
}

#Preview {
  BuildingsView(viewModel: PreviewBuildingViewModel())
    .defaultTheme()
}
