//
//  BuildingsTabView.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

public import BuildingModels
import BuildingViewModels
public import CommonUI
public import RoomModels
import RoomViewModels
public import SwiftUI

// MARK: - BuildingsTabView

public struct BuildingsTabView<BuildingDestination: View, RoomDestination: View>: View {

  // MARK: Lifecycle

  public init(
    path: Binding<NavigationPath>,
    selectedView: Binding<ViewOrientation>,
    _ roomsDestinationBuilderView: @escaping (Building) -> BuildingDestination,
    _ roomDestinationBuilderView: @escaping (Room) -> RoomDestination)
  {
    _path = path
    _selectedView = selectedView
    self.roomsDestinationBuilderView = roomsDestinationBuilderView
    self.roomDestinationBuilderView = roomDestinationBuilderView
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      mainContent
    }
    .alert(item: loadBuildingErrorBinding) { error in
      Alert(
        title: Text(error.title),
        message: Text(error.message),
        dismissButton: .default(Text("OK")))
    }
    .tabItem {
      Label("Buildings", systemImage: "building")
    }
    .tag(FreeroomsTab.buildings)
  }

  // MARK: Internal

  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?
  @Binding var selectedView: ViewOrientation
  @State var cardWidth: CGFloat?
  /// Kept separate from `rowHeight` because nearest rows have different content.
  @State var nearestRowHeight: CGFloat?

  let roomsDestinationBuilderView: (Building) -> BuildingDestination
  let roomDestinationBuilderView: (Room) -> RoomDestination

  @ViewBuilder
  func buildingsCardSegment(for campus: String, from buildings: [Building]) -> some View {
    Section {
      LazyVGrid(columns: columns, spacing: BuildingsTabLayout.cardGridSpacing) {
        ForEach(buildings) { building in
          GenericCardView(
            path: $path,
            cardWidth: $cardWidth,
            building: building,
            buildings: buildings,
            isLoading: buildingViewModel.isLoading,
            isFavourite: .constant(false),
            imageProvider: { roomID in
              BuildingImage[roomID]
            })
        }
      }
      .padding(.horizontal, BuildingsTabLayout.cardGridHorizontalPadding)
      // .listRowSeparator(.hidden)
      // .listRowBackground(Color.clear)
    } header: {
      HStack {
        Text(campus)
          .textCase(.uppercase)
          .foregroundStyle(theme.label.primary)
          .padding(.leading, BuildingsTabLayout.sectionLabelLeadingPadding)
        Spacer()
      }
      .padding(.top, BuildingsTabLayout.sectionHeaderTopPadding)
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
            isLoading: buildingViewModel.isLoading,
            imageProvider: { buildingID in
              BuildingImage[buildingID]
            })
            .padding(.vertical, BuildingsTabLayout.listRowVerticalPadding)
        }
      } header: {
        Text(campus)
          .textCase(.uppercase)
          .foregroundStyle(theme.label.primary)
      }
    }
  }

  @ViewBuilder
  func nearestBuildingsCardSegment() -> some View {
    if showsNearestBuildings {
      let nearest = buildingViewModel.nearestBuildings
      let nearestBuildings = nearest.map(\.building)

      Section {
        LazyVGrid(columns: columns, spacing: BuildingsTabLayout.cardGridSpacing) {
          ForEach(nearest) { nearbyBuilding in
            GenericCardView(
              path: $path,
              cardWidth: $cardWidth,
              item: nearbyBuilding.building,
              items: nearestBuildings,
              isLoading: false,
              isFavourite: .constant(false),
              imageProvider: { buildingID in
                BuildingImage[buildingID]
              })
              .overlay(alignment: .topTrailing) {
                NearbyBuildingDistanceBadge(nearbyBuilding: nearbyBuilding)
                  .padding(NearbyBuildingLayout.badgeInset)
              }
          }
        }
        .padding(.horizontal, BuildingsTabLayout.cardGridHorizontalPadding)
      } header: {
        HStack {
          Text(Self.nearestSectionTitle)
            .textCase(.uppercase)
            .foregroundStyle(theme.label.primary)
            .padding(.leading, BuildingsTabLayout.sectionLabelLeadingPadding)
          Spacer()
        }
        .padding(.top, BuildingsTabLayout.sectionHeaderTopPadding)
      }
    }
  }

  @ViewBuilder
  func nearestBuildingsListSegment() -> some View {
    if showsNearestBuildings {
      let nearest = buildingViewModel.nearestBuildings

      Section {
        ForEach(nearest) { nearbyBuilding in
          GenericListRowView(
            rowHeight: $nearestRowHeight,
            item: nearbyBuilding,
            items: nearest,
            isLoading: false,
            onSelect: { path.append($0.building) },
            imageProvider: { buildingID in
              BuildingImage[buildingID]
            },
            content: { nearbyBuilding in
              NearbyBuildingRowContent(nearbyBuilding: nearbyBuilding)
            })
            .padding(.vertical, BuildingsTabLayout.listRowVerticalPadding)
        }
      } header: {
        Text(Self.nearestSectionTitle)
          .textCase(.uppercase)
          .foregroundStyle(theme.label.primary)
      }
    }
  }

  // MARK: Private

  private static var nearestSectionTitle: String {
    "Nearest to you"
  }

  @Environment(LiveBuildingViewModel.self) private var buildingViewModel
  @Environment(\.scenePhase) private var scenePhase

  @Environment(Theme.self) private var theme
  @Environment(\.colorScheme) private var colorScheme

  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  /// Only show nearest buildings when we have some and the user isn't searching.
  private var showsNearestBuildings: Bool {
    !buildingViewModel.nearestBuildings.isEmpty && buildingViewModel.searchText.isEmpty
  }

  private var searchTextBinding: Binding<String> {
    Binding(
      get: { buildingViewModel.searchText },
      set: { buildingViewModel.searchText = $0 })
  }

  private var loadBuildingErrorBinding: Binding<RoomModels.AlertError?> {
    Binding(
      get: { buildingViewModel.loadBuildingErrorMessage },
      set: { buildingViewModel.loadBuildingErrorMessage = $0 })
  }

  @ViewBuilder
  private var mainContent: some View {
    buildingsView
      .refreshable {
        Task {
          buildingViewModel.reloadBuildings()
        }
      }
      .redacted(reason: buildingViewModel.isLoading ? .placeholder : [])
      .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
          toolbarButtons
        }
      }
      .navigationDestination(for: Building.self) { building in
        roomsDestinationBuilderView(building)
          .navigationTitle(building.name)
          .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: Room.self) { room in
        roomDestinationBuilderView(room)
      }
      .task {
        if !buildingViewModel.hasLoaded {
          buildingViewModel.onAppear()
        } else {
          // Refresh on every return to the tab, e.g. after granting location on the Map tab.
          await buildingViewModel.loadNearestBuildings()
        }
      }
      .onChange(of: scenePhase) { _, newPhase in
        // The location permission prompt makes the app inactive; reload once it's answered.
        guard newPhase == .active else { return }
        Task {
          await buildingViewModel.loadNearestBuildings()
        }
      }
      .navigationTitle("Buildings")
      .searchable(text: searchTextBinding, placement: .navigationBarDrawer(displayMode: .always), prompt: "K17")
  }

  @ViewBuilder
  private var buildingsView: some View {
    if selectedView == ViewOrientation.List {
      List {
        nearestBuildingsListSegment()
        buildingsListSegment(for: "Upper campus", from: buildingViewModel.displayedBuildings.upper)
        buildingsListSegment(for: "Middle campus", from: buildingViewModel.displayedBuildings.middle)
        buildingsListSegment(for: "Lower campus", from: buildingViewModel.displayedBuildings.lower)
      }
      .listRowInsets(EdgeInsets())
      .scrollContentBackground(.hidden)
      .background(theme.background.primary)
    } else {
      ScrollView {
        nearestBuildingsCardSegment()
        buildingsCardSegment(for: "Upper campus", from: buildingViewModel.displayedBuildings.upper)
        buildingsCardSegment(for: "Middle campus", from: buildingViewModel.displayedBuildings.middle)
        buildingsCardSegment(for: "Lower campus", from: buildingViewModel.displayedBuildings.lower)
      }
      // .padding(.horizontal)
      .background(theme.background.primary.opacity(BuildingsTabLayout.backgroundOpacity))
      .shadow(
        color: theme.label.primary.opacity(BuildingsTabLayout.cardShadowOpacity),
        radius: BuildingsTabLayout.cardShadowRadius)
    }
  }

  private var toolbarButtons: some View {
    HStack {
      Button {
        theme.toggleColorScheme(from: colorScheme)
      } label: {
        Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
          .resizable()
          .frame(width: BuildingsTabLayout.toolbarViewToggleIconWidth, height: BuildingsTabLayout.toolbarIconHeight)
      }

      Button {
        buildingViewModel.getBuildingsInOrder()
      } label: {
        Image(systemName: "arrow.up.arrow.down")
          .resizable()
          .frame(width: BuildingsTabLayout.toolbarSortIconWidth, height: BuildingsTabLayout.toolbarIconHeight)
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
          .frame(width: BuildingsTabLayout.toolbarViewToggleIconWidth, height: BuildingsTabLayout.toolbarIconHeight)
      }
    }
    .padding(BuildingsTabLayout.toolbarIconPadding)
    .foregroundStyle(theme.accent.primary)
  }

}

// MARK: - BuildingsTabLayout

private enum BuildingsTabLayout {
  static let backgroundOpacity = 0.1
  static let cardGridHorizontalPadding: CGFloat = 16
  static let cardGridSpacing: CGFloat = 24
  static let cardShadowOpacity = 0.2
  static let cardShadowRadius: CGFloat = 5
  static let listRowVerticalPadding: CGFloat = 5
  static let sectionHeaderTopPadding: CGFloat = 10
  static let sectionLabelLeadingPadding: CGFloat = 10
  static let toolbarIconHeight: CGFloat = 20
  static let toolbarIconPadding: CGFloat = 5
  static let toolbarSortIconWidth: CGFloat = 25
  static let toolbarViewToggleIconWidth: CGFloat = 22
}

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {
  @State var path = NavigationPath()
  @State var selectedView = ViewOrientation.List

  var body: some View {
    let viewModel: LiveBuildingViewModel = PreviewBuildingViewModel()
    BuildingsTabView(
      path: $path,
      selectedView: $selectedView)
    { _ in
      EmptyView() // Buildings destination
    } _: { _ in
      EmptyView() // Rooms destination
    }
    .environment(viewModel)
    .environment(PreviewRoomViewModel() as LiveRoomViewModel)
    .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
