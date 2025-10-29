//
//  BuildingList.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

import BuildingModels
import BuildingViewModels
import CommonUI
import SwiftUI

// MARK: - Room

struct Room: Hashable {
  let name: String
}

// MARK: - BuildingsTabView

public struct BuildingsTabView<Destination: View>: View {

  // MARK: Lifecycle

  public init(
    path: Binding<NavigationPath>,
    viewModel: BuildingViewModel,
    _ roomDestinationBuilderView: @escaping (Building) -> Destination)
  {
    self.viewModel = viewModel
    self.roomDestinationBuilderView = roomDestinationBuilderView
    _path = path
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      List {
        buildingsView(for: "Upper campus", from: viewModel.filteredBuildings.upper)

        buildingsView(for: "Middle campus", from: viewModel.filteredBuildings.middle)

        buildingsView(for: "Lower campus", from: viewModel.filteredBuildings.lower)
      }
      .toolbar {
        // Buttons on the right
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          HStack {
            Button {
              // action
            } label: {
              Image(systemName: "line.3.horizontal.decrease")
                .resizable()
                .frame(width: 22, height: 15)
            }

            Button {
              viewModel.getBuildingsInOrder()
            } label: {
              Image(systemName: "arrow.up.arrow.down")
                .resizable()
                .frame(width: 25, height: 20)
            }

            Button {
              // action
            } label: {
              Image(systemName: "list.bullet")
                .resizable()
                .frame(width: 22, height: 20)
            }
          }
          .padding(.trailing, 10)
          .foregroundStyle(theme.label.tertiary)
        }
      }
      .background(Color.gray.opacity(0.1))
      .listRowInsets(EdgeInsets()) // Removes the large default padding around a list
      .scrollContentBackground(.hidden) // Hides default grey background of the list to allow shadow to appear correctly under section cards
      .shadow(
        color: theme.label.primary.opacity(0.2),
        radius: 5) // Adds a shadow to section cards (and also the section header but thankfully it's not noticeable)
      .navigationDestination(for: Building.self) { building in
        // Renders the view for displaying a building that has been clicked on
        roomDestinationBuilderView(building)
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
        .onAppear {
          if !viewModel.hasLoaded {
            viewModel.onAppear()
          }
        }
        .navigationTitle("Buildings")
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
    }
    .tabItem {
      Label("Buildings", systemImage: "building")
    }
    .tag("Buildings") // Sets the selected tab to "Buildings"
  }

  // MARK: Internal

  @State var viewModel: BuildingViewModel
  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?

  let roomDestinationBuilderView: (Building) -> Destination

  @ViewBuilder
  func buildingsView(for campus: String, from buildings: [Building]) -> some View {
    if buildings.isEmpty {
      EmptyView()
    } else {
      Section {
        ForEach(buildings) { building in
          GenericListRowView(
            path: $path,
            rowHeight: $rowHeight,
            building: building,
            buildings: buildings,
            imageProvider: { buildingID in
              BuildingImage[buildingID] // This closure captures BuildingImage
            })
            .padding(.vertical, 5)
        }
      } header: {
        Text(campus)
          .foregroundStyle(theme.label.primary)
      }
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
}

// MARK: - PreviewWrapper

struct PreviewWrapper: View {
  @State var path = NavigationPath()

  var body: some View {
    BuildingsTabView(path: $path, viewModel: PreviewBuildingViewModel()) { _ in
      EmptyView()
    }
    .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
