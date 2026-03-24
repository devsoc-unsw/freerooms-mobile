//
//  BuildingsTabView.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

import BuildingModels
import BuildingViewModels
import CommonUI
import RoomModels
import SwiftUI

// MARK: - BuildingsTabView

public struct BuildingsTabView<BuildingDestination: View, RoomDestination: View>: View {

  // MARK: Lifecycle

  public init(
    path: Binding<NavigationPath>,
    viewModel: BuildingViewModel,
    selectedView: Binding<ViewOrientation>,
    _ roomsDestinationBuilderView: @escaping (Building) -> BuildingDestination,
    _ roomDestinationBuilderView: @escaping (Room) -> RoomDestination)
  {
    _path = path
    _selectedView = selectedView
    self.viewModel = viewModel
    self.roomsDestinationBuilderView = roomsDestinationBuilderView
    self.roomDestinationBuilderView = roomDestinationBuilderView
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      buildingsView
        .refreshable {
          Task {
            await viewModel.reloadBuildings()
          }
        }
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .toolbar {
          // Buttons on the right
          ToolbarItemGroup(placement: .navigationBarTrailing) {
            HStack {
              Button {
                viewModel.getBuildingsInOrder()
              } label: {
                Image(systemName: "arrow.up.arrow.down")
                  .resizable()
                  .frame(width: 25, height: 20)
              }

              Button {
                if selectedView == ViewOrientation.Card {
                  selectedView = ViewOrientation.List
                } else {
                  selectedView = ViewOrientation.Card
                }
              } label: {
                Image(systemName: selectedView == ViewOrientation.List ? "square.grid.2x2" : "list.bullet")
                  .resizable()
                  .frame(width: 22, height: 20)
              }
            }
            .padding(5)
            .foregroundStyle(theme.label.tertiary)
          }
        }
        .navigationDestination(for: Building.self) { building in
          roomsDestinationBuilderView(building)
            .navigationTitle(building.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationDestination(for: Room.self) { room in // Renders the view for displaying a room that has been clicked on
          roomDestinationBuilderView(room)
        }
        .onAppear {
          if !viewModel.hasLoaded {
            viewModel.onAppear()
          }
        }
        .navigationTitle("Buildings")
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "K17")
    }
    .alert(item: $viewModel.loadBuildingErrorMessage) { error in
      Alert(
        title: Text(error.title),
        message: Text(error.message),
        dismissButton: .default(Text("OK")))
    }
    .tabItem {
      Label("Buildings", systemImage: "building")
    }
    .tag("Buildings")
  }

  // MARK: Internal

  @State var viewModel: BuildingViewModel
  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?
  @Binding var selectedView: ViewOrientation
  @State var cardWidth: CGFloat?

  let roomsDestinationBuilderView: (Building) -> BuildingDestination
  let roomDestinationBuilderView: (Room) -> RoomDestination

  @ViewBuilder
  func buildingsCardSegment(for campus: String, from buildings: [Building]) -> some View {
    Section {
      LazyVGrid(columns: columns, spacing: 24) {
        ForEach(buildings) { building in
          GenericCardView(
            path: $path,
            cardWidth: $cardWidth,
            building: building,
            buildings: buildings,
            isLoading: viewModel.isLoading,
            imageProvider: { roomID in
              BuildingImage[roomID]
            })
        }
      }
      .padding(.horizontal, 16)
      // .listRowSeparator(.hidden)
      // .listRowBackground(Color.clear)
    } header: {
      HStack {
        Text(campus)
          .textCase(.uppercase)
          .foregroundStyle(theme.label.primary)
          .padding(.leading, 10)
        Spacer()
      }
      .padding(.top, 10)
    }
  }

  @ViewBuilder
  func buildingsListSegment(for campus: String, from buildings: [Building]) -> some View {
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
            isLoading: viewModel.isLoading,
            imageProvider: { buildingID in
              BuildingImage[buildingID]
            })
            .padding(.vertical, 5)
        }
      } header: {
        Text(campus)
          .textCase(.uppercase)
          .foregroundStyle(theme.label.primary)
      }
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  @ViewBuilder
  private var buildingsView: some View {
    if selectedView == ViewOrientation.List {
      List {
        buildingsListSegment(for: "Upper campus", from: viewModel.displayedBuildings.upper)
        buildingsListSegment(for: "Middle campus", from: viewModel.displayedBuildings.middle)
        buildingsListSegment(for: "Lower campus", from: viewModel.displayedBuildings.lower)
      }
      .listRowInsets(EdgeInsets())
      .scrollContentBackground(.hidden)
      .background(Color.gray.opacity(0.1))
    } else {
      ScrollView {
        buildingsCardSegment(for: "Upper campus", from: viewModel.displayedBuildings.upper)
        buildingsCardSegment(for: "Middle campus", from: viewModel.displayedBuildings.middle)
        buildingsCardSegment(for: "Lower campus", from: viewModel.displayedBuildings.lower)
      }
      // .padding(.horizontal)
      .background(Color.gray.opacity(0.1))
      .shadow(color: theme.label.primary.opacity(0.2), radius: 5)
    }
  }

}

// MARK: - PreviewWrapper

struct PreviewWrapper: View {
  @State var path = NavigationPath()
  @State var selectedView = ViewOrientation.List

  var body: some View {
    BuildingsTabView(
      path: $path,
      viewModel: PreviewBuildingViewModel(),
      selectedView: $selectedView)
    { _ in
      EmptyView() // Buildings destination
    } _: { _ in
      EmptyView() // Rooms destination
    }
    .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
