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
    _ roomDestinationBuilderView: @escaping (Room) -> Destination)
  {
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
          ? "door.left.hand.open"
          : "door.left.hand.closed")
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
    _ buildings: [Building])
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
            cardWidth: $cardWidth)
        } header: {
          HStack {
            Text(building.name)
              .textCase(.uppercase)
              .foregroundStyle(theme.label.primary)
              .padding(
                .leading,
                RoomLayoutConstants.sectionHeaderLeadingPadding)
            Spacer()
          }
          .padding(.horizontal, RoomLayoutConstants.contentHorizontalPadding)
          .padding(.top, RoomLayoutConstants.sectionHeaderTopPadding)
        }
      }
    }
  }

  func roomsListView(
    _ buildings: [Building])
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
            rowHeight: $rowHeight)
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
      set: { roomViewModel.searchText = $0 })
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
                  duration: RoomLayoutConstants.filterMenuAnimationDuration))
              {
                showingFilterMenu = false
              }
            }
        }
      }
      .overlay(alignment: .bottomTrailing) {
        if !roomViewModel.isLoading {
          FloatingFilterMenuView(
            activeFilterSheet: $activeFilterSheet,
            showingFilterMenu: $showingFilterMenu)
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
      .navigationDestination(for: RoomsDestination.self) { destination in
        switch destination {
        case .favorites:
          FavoriteRoomsView(
            path: $path,
            selectedView: $selectedView)
        }
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
          set: { roomViewModel.loadRoomErrorMessage = $0 }))
      { error in
        Alert(
          title: Text(error.title),
          message: Text(error.message),
          dismissButton: .default(Text("OK")))
      }
      .navigationTitle("Rooms")
      .searchable(
        text: searchTextBinding,
        placement: .navigationBarDrawer(displayMode: .always),
        prompt: "Search...")
      .roomFilterSheets(activeFilterSheet: $activeFilterSheet)
  }

  @ViewBuilder
  private var roomView: some View {
    if selectedView == ViewOrientation.List {
      if roomViewModel.isLoading, roomViewModel.roomsByBuildingId.isEmpty {
        let placeholderRooms = roomViewModel.getPlaceHolderRooms(
          for: "placeholder")
        List {
          RoomList(
            rooms: placeholderRooms,
            isLoading: true,
            path: $path,
            rowHeight: $rowHeight)
        }
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .background(theme.background.primary)
      } else {
        List {
          favoriteRoomsPreview
          roomsListView(roomSectionBuildings)
        }
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .background(theme.background.primary)
      }
    } else {
      if roomViewModel.isLoading, roomViewModel.roomsByBuildingId.isEmpty {
        let placeholderRooms = roomViewModel.getPlaceHolderRooms(
          for: "placeholder")
        ScrollView {
          RoomCardGrid(
            rooms: placeholderRooms,
            isLoading: true,
            path: $path,
            cardWidth: $cardWidth)
        }
        .background(Color.gray.opacity(RoomLayoutConstants.backgroundOpacity))
        .shadow(
          color: theme.label.primary.opacity(
            RoomLayoutConstants.cardShadowOpacity),
          radius: RoomLayoutConstants.cardShadowRadius)
      } else {
        ScrollView {
          favoriteRoomsPreview
          roomsCardView(roomSectionBuildings)
        }
        .background(theme.background.primary)
        .shadow(
          color: theme.label.primary.opacity(
            RoomLayoutConstants.cardShadowOpacity),
          radius: RoomLayoutConstants.cardShadowRadius)
      }
    }
  }

  @ViewBuilder
  private var favoriteRoomsPreview: some View {
    let favoriteRooms = roomViewModel.getAllFavoriteRooms()
    // Keep the inline section compact; the full list lives at `.favorites`.
    let previewRooms = Array(favoriteRooms.prefix(4))

    if !favoriteRooms.isEmpty {
      Section {
        if selectedView == ViewOrientation.List {
          RoomList(
            rooms: previewRooms,
            isLoading: roomViewModel.isLoading,
            path: $path,
            rowHeight: $rowHeight)
        } else {
          RoomCardGrid(
            rooms: previewRooms,
            isLoading: roomViewModel.isLoading,
            path: $path,
            cardWidth: $cardWidth)
        }

        if favoriteRooms.count > 4 {
          Button {
            path.append(RoomsDestination.favorites)
          } label: {
            HStack(spacing: 4) {
              Text("See More")
                .fontWeight(.semibold)

              Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(theme.label.tertiary)
            .padding(.vertical, 12)
          }
          .buttonStyle(.plain)
          .padding(
            .horizontal,
            RoomLayoutConstants.contentHorizontalPadding)
          .listRowInsets(EdgeInsets())
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
        }
      } header: {
        if selectedView == ViewOrientation.List {
          Text("Favorites")
            .textCase(.uppercase)
            .foregroundStyle(theme.label.primary)
        } else {
          HStack {
            Text("Favorites")
              .textCase(.uppercase)
              .foregroundStyle(theme.label.primary)
              .padding(
                .leading,
                RoomLayoutConstants.sectionHeaderLeadingPadding)

            Spacer()
          }
          .padding(
            .horizontal,
            RoomLayoutConstants.contentHorizontalPadding)
          .padding(
            .top,
            RoomLayoutConstants.sectionHeaderTopPadding)
        }
      }
    }
  }

  private static func placeholderBuilding(id: String, name: String) -> Building {
    Building(
      name: name,
      id: id,
      latitude: 0,
      longitude: 0,
      aliases: [],
      numberOfAvailableRooms: 0)
  }
}

// MARK: - RoomsDestination

private enum RoomsDestination: Hashable {
  case favorites
}

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {
  @State var path = NavigationPath()
  @State var selectedView = ViewOrientation.List

  var body: some View {
    RoomsTabView<EmptyView>(
      path: $path,
      selectedTab: .constant(.rooms),
      selectedView: $selectedView)
    { _ in
      EmptyView() // Buildings destination
    }
    .environment(PreviewBuildingViewModel() as LiveBuildingViewModel)
    .environment(PreviewRoomViewModel() as LiveRoomViewModel)
    .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
