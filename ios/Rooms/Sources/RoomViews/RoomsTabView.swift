//
//  RoomsTabView.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

import BuildingModels
import BuildingViewModels
import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - RoomsTabView

public struct RoomsTabView<Destination: View>: View {

  // MARK: Lifecycle

  /// init some viewModel to depend on
  public init(
    path: Binding<NavigationPath>,
    selectedTab: Binding<FreeroomsTab>,
    selectedView: Binding<ViewOrientation>,
    _ roomDestinationBuilderView: @escaping (Room) -> Destination
  ) {
    _path = path
    _selectedTab = selectedTab
    _selectedView = selectedView
    self.roomDestinationBuilderView = roomDestinationBuilderView
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      mainContent
    }
    .tabItem {
      Label(
        "Rooms",
        systemImage: selectedTab == .rooms
          ? "door.left.hand.open" : "door.left.hand.closed"
      )
    }
    .tag(FreeroomsTab.rooms)
  }

  // MARK: Internal

  @Binding var selectedTab: FreeroomsTab
  @Binding var selectedView: ViewOrientation
  @State var cardWidth: CGFloat?
  @State var searchText = ""
  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?

  func roomsCardView(
    _ buildings: [Building]
  )
    -> some View
  {
    ForEach(buildings) { building in
      let rooms = roomViewModel.getDisplayedRooms(for: building.id)

      if rooms.isEmpty {
        EmptyView()
      } else {
        Section {
          RoomCardGrid(
            rooms: rooms,
            isLoading: roomViewModel.isLoading,
            path: $path,
            cardWidth: $cardWidth
          )
        } header: {
          HStack {
            Text(building.name)
              .textCase(.uppercase)
              .foregroundStyle(theme.label.primary)
              .padding(
                .leading,
                RoomLayoutConstants.sectionHeaderLeadingPadding
              )
            Spacer()
          }
          .padding(.horizontal, RoomLayoutConstants.contentHorizontalPadding)
          .padding(.top, RoomLayoutConstants.sectionHeaderTopPadding)
        }
      }
    }
  }

  func roomsListView(
    _ buildings: [Building]
  )
    -> some View
  {
    ForEach(buildings) { building in
      let rooms = roomViewModel.getDisplayedRooms(for: building.id)

      if !rooms.isEmpty {
        Section {
          RoomList(
            rooms: rooms,
            isLoading: roomViewModel.isLoading,
            path: $path,
            rowHeight: $rowHeight
          )
        } header: {
          Text(building.name)
            .textCase(.uppercase)
            .foregroundStyle(theme.label.primary)
        }
      }
    }
  }

  // MARK: Private

  @State private var activeFilterSheet: RoomFilterSheet?
  @State private var showingFilterMenu = false

  @Environment(Theme.self) private var theme
  @Environment(LiveBuildingViewModel.self) private var buildingViewModel
  @Environment(LiveRoomViewModel.self) private var roomViewModel

  private let roomDestinationBuilderView: (Room) -> Destination

  private var favoriteRooms: [Room] {
    roomViewModel.getAllFavoriteRooms()
  }

  private var roomSectionBuildings: [Building] {
    let buildings = buildingViewModel.allBuildings
    if !buildings.isEmpty {
      return buildings
    }

    // Preserve room sections while building metadata is still unavailable.
    return roomViewModel.roomsByBuildingId.keys
      .sorted()
      .map { Self.placeholderBuilding(id: $0, name: $0) }
  }

  private var searchTextBinding: Binding<String> {
    Binding(
      get: { roomViewModel.searchText },
      set: { roomViewModel.searchText = $0 }
    )
  }

  @ViewBuilder
  private var mainContent: some View {
    roomView
      .refreshable {
        Task {
          await roomViewModel.reloadRooms()
        }
      }
      .redacted(reason: roomViewModel.isLoading ? .placeholder : [])
      .overlay {
        if showingFilterMenu, !roomViewModel.isLoading {
          Color.black
            .opacity(RoomLayoutConstants.filterMenuScrimOpacity)
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
              withAnimation(
                .spring(
                  duration: RoomLayoutConstants.filterMenuAnimationDuration
                )
              ) {
                showingFilterMenu = false
              }
            }
        }
      }
      .overlay(alignment: .bottomTrailing) {
        if !roomViewModel.isLoading {
          FloatingFilterMenuView(
            activeFilterSheet: $activeFilterSheet,
            showingFilterMenu: $showingFilterMenu
          )
          .padding(.trailing, RoomLayoutConstants.filterMenuTrailingPadding)
          .padding(.bottom, RoomLayoutConstants.filterMenuBottomPadding)
        }
      }
      .toolbar {
        RoomToolBar(selectedView: $selectedView)
      }
      .background(Color.gray.opacity(0.1))
      .listRowInsets(EdgeInsets())
      .scrollContentBackground(.hidden)
      .navigationDestination(for: Room.self) { room in
        roomDestinationBuilderView(room)
      }
      .task {
        if !buildingViewModel.hasLoaded {
          buildingViewModel.onAppear()
        }

        if !roomViewModel.hasLoaded {
          await roomViewModel.onAppear()
        }
      }
      .alert(
        item: Binding(
          get: { roomViewModel.loadRoomErrorMessage },
          set: { roomViewModel.loadRoomErrorMessage = $0 }
        )
      ) { error in
        Alert(
          title: Text(error.title),
          message: Text(error.message),
          dismissButton: .default(Text("OK"))
        )
      }
      .navigationTitle("Rooms")
      .searchable(
        text: searchTextBinding,
        placement: .navigationBarDrawer(displayMode: .always),
        prompt: "Search..."
      )
      .roomFilterSheets(activeFilterSheet: $activeFilterSheet)
  }

  @ViewBuilder
  private var roomView: some View {
    if selectedView == ViewOrientation.List {
      if roomViewModel.isLoading, roomViewModel.roomsByBuildingId.isEmpty {
        let placeholderRooms = roomViewModel.getPlaceHolderRooms(
          for: "placeholder"
        )
        List {
          RoomList(
            rooms: placeholderRooms,
            isLoading: true,
            path: $path,
            rowHeight: $rowHeight
          )
        }
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .background(theme.background.primary)
      } else {
        List {
          roomsListView(roomSectionBuildings)
        }
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .background(theme.background.primary)
      }
    } else {
      if roomViewModel.isLoading, roomViewModel.roomsByBuildingId.isEmpty {
        let placeholderRooms = roomViewModel.getPlaceHolderRooms(
          for: "placeholder"
        )
        ScrollView {
          RoomCardGrid(
            rooms: placeholderRooms,
            isLoading: true,
            path: $path,
            cardWidth: $cardWidth
          )
        }
        .background(Color.gray.opacity(RoomLayoutConstants.backgroundOpacity))
        .shadow(
          color: theme.label.primary.opacity(
            RoomLayoutConstants.cardShadowOpacity
          ),
          radius: RoomLayoutConstants.cardShadowRadius
        )
      } else {
        ScrollView {
          roomsCardView(roomSectionBuildings)
        }
        .background(theme.background.primary)
        .shadow(
          color: theme.label.primary.opacity(RoomLayoutConstants.cardShadowOpacity),
          radius: RoomLayoutConstants.cardShadowRadius)
      }
    }
  }

  private var toolbarButtons: some View {
    HStack {
      Button {
        theme.toggleColorScheme(from: colorScheme)
      } label: {
        Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
          .resizable()
          .frame(width: RoomLayoutConstants.toolbarViewToggleIconWidth, height: RoomLayoutConstants.toolbarIconHeight)
      }

      Button {
        roomViewModel.getRoomsInOrder()
      } label: {
        Image(systemName: "arrow.up.arrow.down")
          .resizable()
          .frame(width: RoomLayoutConstants.toolbarSortIconWidth, height: RoomLayoutConstants.toolbarIconHeight)
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
          .frame(width: RoomLayoutConstants.toolbarViewToggleIconWidth, height: RoomLayoutConstants.toolbarIconHeight)
      }
    }
    .padding(RoomLayoutConstants.toolbarIconPadding)
    .foregroundStyle(theme.accent.primary)
  }

  private static func placeholderBuilding(id: String, name: String) -> Building {
    Building(
      name: name,
      id: id,
      latitude: 0,
      longitude: 0,
      aliases: [],
      numberOfAvailableRooms: 0
    )
  }
}

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {
  @State var path = NavigationPath()
  @State var selectedView = ViewOrientation.List

  var body: some View {
    RoomsTabView<EmptyView>(
      path: $path,
      selectedTab: .constant(.rooms),
      selectedView: $selectedView
    ) { _ in
      EmptyView()  // Buildings destination
    }
    .environment(PreviewBuildingViewModel() as LiveBuildingViewModel)
    .environment(PreviewRoomViewModel() as LiveRoomViewModel)
    .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
