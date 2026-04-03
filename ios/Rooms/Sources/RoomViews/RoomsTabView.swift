//
//  RoomsTabView.swift
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
          LazyVGrid(columns: columns, spacing: 24) {
            ForEach(rooms) { room in
              GenericCardView(
                path: $path,
                cardWidth: $cardWidth,
                room: room,
                rooms: rooms,
                isLoading: roomViewModel.isLoading,
                imageProvider: { roomID in
                  RoomImage[roomID]
                })
            }
          }
          .padding(.horizontal, 16)
        } header: {
          HStack {
            Text(buildingName)
              .textCase(.uppercase)
              .foregroundStyle(theme.label.primary)
              .padding(.leading, 10)
            Spacer()
          }
          .padding(.horizontal, 16)
          .padding(.top, 10)
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
              .padding(.vertical, 5)
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

  // Filter sheet states
  @State private var showingDateFilter = false
  @State private var showingRoomTypeFilter = false
  @State private var showingDurationFilter = false
  @State private var showingCampusLocationFilter = false
  @State private var showingCapacityFilter = false
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
        if roomViewModel.isLoading {
          VStack(spacing: 12) {
            ProgressView()
              .controlSize(.large)
            Text(roomViewModel.isLoading ? "Loading rooms..." : "Applying filters...")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(.ultraThinMaterial)
        }
      }
      .overlay(alignment: .bottomTrailing) {
        FloatingFilterMenuView(
          showingDateFilter: $showingDateFilter,
          showingRoomTypeFilter: $showingRoomTypeFilter,
          showingDurationFilter: $showingDurationFilter,
          showingCampusLocationFilter: $showingCampusLocationFilter,
          showingCapacityFilter: $showingCapacityFilter,
          showingFilterMenu: $showingFilterMenu)
          .padding(.trailing, 16)
          .padding(.bottom, 8)
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
      .sheet(isPresented: $showingDateFilter) {
        DateFilterView(selectedDate: selectedDateBinding) {
          showingDateFilter = false
          roomViewModel.applyFilters()
          let vm = roomViewModel
          Task { await vm.loadBookingsForFilteredRooms() }
        }
        .environment(roomViewModel)
        .presentationDetents([.fraction(0.8)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
      }
      .sheet(isPresented: $showingRoomTypeFilter) {
        RoomTypeFilterView(selectedRoomTypes: selectedRoomTypesBinding) {
          showingRoomTypeFilter = false
          roomViewModel.applyFilters()
        }
        .environment(roomViewModel)
        .presentationDetents([.fraction(0.52)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
      }
      .sheet(isPresented: $showingDurationFilter) {
        DurationFilterView(onSelect: {
          showingDurationFilter = false
          roomViewModel.applyFilters()
        })
        .environment(roomViewModel)
        .presentationDetents([.fraction(0.32)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
      }
      .sheet(isPresented: $showingCampusLocationFilter) {
        CampusLocationFilterView(selectedCampusLocation: selectedCampusLocationBinding) {
          showingCampusLocationFilter = false
          roomViewModel.applyFilters()
        }
        .environment(roomViewModel)
        .presentationDetents([.fraction(0.44)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
      }
      .sheet(isPresented: $showingCapacityFilter) {
        CapacityFilterView(selectedCapacity: selectedCapacityBinding) {
          showingCapacityFilter = false
          roomViewModel.applyFilters()
        }
        .environment(roomViewModel)
        .presentationDetents([.fraction(0.47)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(.systemBackground))
      }
  }

  @ViewBuilder
  private var roomView: some View {
    if selectedView == ViewOrientation.List {
      List {
        roomsListView(buildingViewModel.allBuildings)
      }
      .listRowInsets(EdgeInsets())
      .scrollContentBackground(.hidden)
      .background(Color.gray.opacity(0.1))
    } else {
      ScrollView {
        roomsCardView(buildingViewModel.allBuildings)
      }
      .background(Color.gray.opacity(0.1))
      .shadow(color: theme.label.primary.opacity(0.2), radius: 5)
    }
  }

  private var toolbarButtons: some View {
    HStack {
      Button {
        roomViewModel.getRoomsInOrder()
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
    .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
