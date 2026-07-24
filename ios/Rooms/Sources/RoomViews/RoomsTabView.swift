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
    selectedTab: Binding<String>,
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
    .onDisappear {
      roomViewModel.searchText = String()
    }
    .tabItem {
      Label("Rooms", systemImage: selectedTab == "Rooms" ? "door.left.hand.open" : "door.left.hand.closed")
    }
    .tag("Rooms")
  }

  // MARK: Internal

  @Binding var selectedTab: String
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
      let buildingName = buildings.first(where: { $0.id == building.id })?.name ?? building.id

      if rooms.isEmpty {
        EmptyView()
      } else {
        Section {
          LazyVGrid(columns: columns, spacing: RoomLayoutConstants.cardGridSpacing) {
            ForEach(rooms) { room in
              GenericCardView(
                path: $path,
                cardWidth: $cardWidth,
                room: room,
                rooms: rooms,
                isLoading: roomViewModel.isLoading,
                isFavourite: Binding(
                  get: {
                    roomViewModel.isFavorite(roomID: room.id)
                  },
                  set: { _ in
                    roomViewModel.toggleFavorite(roomID: room.id)
                  }),
                imageProvider: { roomID in
                  RoomImage[roomID]
                })
            }
          }
          .padding(.horizontal, RoomLayoutConstants.contentHorizontalPadding)
        } header: {
          HStack {
            Text(buildingName)
              .textCase(.uppercase)
              .foregroundStyle(theme.label.primary)
              .padding(.leading, RoomLayoutConstants.sectionHeaderLeadingPadding)
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
      let buildingName = buildings.first(where: { $0.id == building.id })?.name ?? building.id

      if rooms.isEmpty {
        EmptyView()
      } else {
        Section {
          ForEach(rooms) { room in
            GenericListRowView(
              path: $path,
              rowHeight: $rowHeight,
              room: room,
              rooms: rooms,
              isLoading: roomViewModel.isLoading,
              imageProvider: { roomID in
                RoomImage[roomID]
              })
              .padding(.vertical, RoomLayoutConstants.listRowVerticalPadding)
          }
        } header: {
          Text(buildingName)
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

  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  private let roomDestinationBuilderView: (Room) -> Destination

  private var searchTextBinding: Binding<String> {
    Binding(
      get: { roomViewModel.searchText },
      set: { roomViewModel.searchText = $0 })
  }

  private var selectedDateBinding: Binding<Date> {
    Binding(
      get: { roomViewModel.selectedDate },
      set: { roomViewModel.selectedDate = $0 })
  }

  private var selectedRoomTypesBinding: Binding<Set<RoomType>> {
    Binding(
      get: { roomViewModel.selectedRoomTypes },
      set: { roomViewModel.selectedRoomTypes = $0 })
  }

  private var selectedCampusLocationBinding: Binding<CampusLocation?> {
    Binding(
      get: { roomViewModel.selectedCampusLocation },
      set: { roomViewModel.selectedCampusLocation = $0 })
  }

  private var selectedCapacityBinding: Binding<Int?> {
    Binding(
      get: { roomViewModel.selectedCapacity },
      set: { roomViewModel.selectedCapacity = $0 })
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
              withAnimation(.spring(duration: RoomLayoutConstants.filterMenuAnimationDuration)) {
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
        toolbarButtons
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
      .alert(item: Binding(
        get: { roomViewModel.loadRoomErrorMessage },
        set: { roomViewModel.loadRoomErrorMessage = $0 }))
      { error in
        Alert(
          title: Text(error.title),
          message: Text(error.message),
          dismissButton: .default(Text("OK")))
      }
      .navigationTitle("Rooms")
      .searchable(text: searchTextBinding, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
      .sheet(item: $activeFilterSheet) { sheet in
        switch sheet {
        case .date:
          DateFilterView(selectedDate: selectedDateBinding) {
            activeFilterSheet = nil
            Task { await roomViewModel.applyFilters() }
            let vm = roomViewModel
            Task { await vm.loadBookingsForFilteredRooms() }
          }
          .environment(roomViewModel)
          .environment(theme)
          .presentationDetents([FilterSheetLayout.dateDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))

        case .roomType:
          RoomTypeFilterView(selectedRoomTypes: selectedRoomTypesBinding) {
            activeFilterSheet = nil
            Task { await roomViewModel.applyFilters() }
          }
          .environment(roomViewModel)
          .environment(theme)
          .presentationDetents([FilterSheetLayout.roomTypeDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))

        case .duration:
          DurationFilterView(onSelect: {
            activeFilterSheet = nil
            Task { await roomViewModel.applyFilters() }
          })
          .environment(roomViewModel)
          .environment(theme)
          .presentationDetents([FilterSheetLayout.durationDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))

        case .campusLocation:
          CampusLocationFilterView(selectedCampusLocation: selectedCampusLocationBinding) {
            activeFilterSheet = nil
            Task { await roomViewModel.applyFilters() }
          }
          .environment(roomViewModel)
          .environment(theme)
          .presentationDetents([FilterSheetLayout.campusLocationDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))

        case .capacity:
          CapacityFilterView(selectedCapacity: selectedCapacityBinding) {
            activeFilterSheet = nil
            Task { await roomViewModel.applyFilters() }
          }
          .environment(roomViewModel)
          .environment(theme)
          .presentationDetents([FilterSheetLayout.capacityDetent])
          .presentationDragIndicator(.visible)
          .presentationBackground(Color(.systemBackground))
        }
      }
  }

  @ViewBuilder
  private var roomView: some View {
    if selectedView == ViewOrientation.List {
      if roomViewModel.isLoading, buildingViewModel.allBuildings.isEmpty {
        let placeholderRooms = roomViewModel.getPlaceHolderRooms(for: "placeholder")
        List {
          ForEach(placeholderRooms) { room in
            GenericListRowView(
              path: $path,
              rowHeight: $rowHeight,
              room: room,
              rooms: placeholderRooms,
              isLoading: true,
              imageProvider: { roomID in
                RoomImage[roomID]
              })
              .padding(.vertical, RoomLayoutConstants.listRowVerticalPadding)
          }
        }
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .background(theme.background.primary)
      } else {
        List {
          roomsListView(buildingViewModel.allBuildings)
        }
        .listRowInsets(EdgeInsets())
        .scrollContentBackground(.hidden)
        .background(theme.background.primary)
      }
    } else {
      if roomViewModel.isLoading, buildingViewModel.allBuildings.isEmpty {
        let placeholderRooms = roomViewModel.getPlaceHolderRooms(for: "placeholder")
        ScrollView {
          LazyVGrid(columns: columns, spacing: RoomLayoutConstants.cardGridSpacing) {
            ForEach(placeholderRooms) { room in
              GenericCardView(
                path: $path,
                cardWidth: $cardWidth,
                room: room,
                rooms: placeholderRooms,
                isLoading: true,
                isFavourite: .constant(false),
                imageProvider: { roomID in
                  RoomImage[roomID]
                })
            }
          }
          .padding(.horizontal, RoomLayoutConstants.contentHorizontalPadding)
        }
        .background(Color.gray.opacity(RoomLayoutConstants.backgroundOpacity))
        .shadow(
          color: theme.label.primary.opacity(RoomLayoutConstants.cardShadowOpacity),
          radius: RoomLayoutConstants.cardShadowRadius)
      } else {
        ScrollView {
          roomsCardView(buildingViewModel.allBuildings)
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
}

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {
  @State var path = NavigationPath()
  @State var selectedView = ViewOrientation.List

  var body: some View {
    RoomsTabView<EmptyView>(
      path: $path,
      selectedTab: .constant("Rooms"),
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
