//
//  BuildingList.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

import Buildings
import CommonUI
import SwiftUI

// MARK: - Room

struct Room: Hashable {
  let name: String
}

// MARK: - BuildingsTabView

public struct BuildingsTabView: View {

  // MARK: Lifecycle

  public init(viewModel: BuildingViewModel) {
    self.viewModel = viewModel
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      List {
        buildingsView(for: "Upper campus", from: viewModel.upperCampusBuildings)

        buildingsView(for: "Middle campus", from: viewModel.middleCampusBuildings)
      }
      .listRowInsets(EdgeInsets()) // Removes the large default padding around a list
      .scrollContentBackground(.hidden) // Hides default grey background of the list to allow shadow to appear correctly under section cards
      .shadow(
        color: theme.label.primary.opacity(0.2),
        radius: 5) // Adds a shadow to section cards (and also the section header but thankfully it's not noticeable)
      .navigationDestination(for: Building.self) { building in
        // Renders the view for displaying a building that has been clicked on
        Button {
          path.append(Room(name: "bruh"))
        } label: {
          Text("bruh")
        }
        .navigationTitle(building.name)
        .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: Room.self) { room in // Renders the view for displaying a room that has been clicked on
        Text(room.name)
          .navigationTitle(room.name)
      }
      .opacity(
        viewModel.isLoading
          ? 0
          : 1) // This hides a glitch where the bottom border of top section row and vice versa flashes when changing order
        .onAppear(perform: viewModel.onAppear)
        .navigationTitle("Buildings")
    }
    .overlay(alignment: .bottom) {
      Button("Buildings in ascending order: \(viewModel.buildingsInAscendingOrder)", action: viewModel.getBuildingsInOrder)
        .buttonStyle(.borderedProminent)
        .padding(.bottom)
    }
    .tabItem {
      Label("Buildings", systemImage: "building")
    }
    .tag("Buildings") // Sets the selected tab to "Buildings"
  }

  // MARK: Internal

  @State var viewModel: BuildingViewModel

  @State var path = NavigationPath()
  @State var rowHeight: CGFloat?

  func buildingsView(for campus: String, from buildings: [Building]) -> some View {
    Section {
      ForEach(buildings) { building in
        BuildingListRowView(path: $path, rowHeight: $rowHeight, building: building, buildings: buildings)
          .padding(.vertical, 5)
      }
    } header: {
      Text(campus)
        .foregroundStyle(theme.label.primary)
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
}

#Preview {
  BuildingsTabView(viewModel: PreviewBuildingViewModel())
    .defaultTheme()
}
