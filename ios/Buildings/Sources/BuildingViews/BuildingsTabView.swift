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

        buildingsView(for: "Lower campus", from: viewModel.lowerCampusBuildings)
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
                .frame(width: 22, height: 15)
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
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
  @State var searchText = ""

  func buildingsView(for campus: String, from buildings: [Building]) -> some View {
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

  // MARK: Private

  @Environment(Theme.self) private var theme
}

#Preview {
  BuildingsTabView(viewModel: PreviewBuildingViewModel())
    .defaultTheme()
}
