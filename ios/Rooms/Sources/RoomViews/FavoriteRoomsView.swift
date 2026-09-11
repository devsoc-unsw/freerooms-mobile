//
//  FavoriteRoomsView.swift
//  Rooms
//
//  Created by Nicole Xie on 2026/9/11.
//

import CommonUI
import BuildingViewModels
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - FavoriteRoomsView

struct FavoriteRoomsView<Destination: View>: View {

  // MARK: Lifecycle
  
  init(
    path: Binding<NavigationPath>,
    selectedView: Binding<ViewOrientation>,
    _ roomDestinationBuilderView: @escaping (Room) -> Destination)
  {
    _path = path
    _selectedView = selectedView
    self.roomDestinationBuilderView = roomDestinationBuilderView
  }

  // MARK: Internal
  
  @Binding var path: NavigationPath
  @Binding var selectedView: ViewOrientation
  
  var body: some View {
    roomView
      .refreshable {
        Task {
          await roomViewModel.reloadRooms()
        }
      }
      .redacted(reason: roomViewModel.isLoading ? .placeholder : [])
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
      .background(
        Color.gray.opacity(RoomLayoutConstants.backgroundOpacity))
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
      .navigationTitle("Favorites")
      .searchable(
        text: searchTextBinding,
        placement: .navigationBarDrawer(displayMode: .always),
        prompt: "Search...")
      .roomFilterSheets(
        activeFilterSheet: $activeFilterSheet)
  }
  
  // MARK: Private

  @State private var cardWidth: CGFloat?
  @State private var rowHeight: CGFloat?

  @State private var activeFilterSheet: RoomFilterSheet?
  @State private var showingFilterMenu = false

  @Environment(Theme.self) private var theme
  @Environment(LiveBuildingViewModel.self) private var buildingViewModel
  @Environment(LiveRoomViewModel.self) private var roomViewModel

  private let roomDestinationBuilderView: (Room) -> Destination

  private var favoriteRooms: [Room] {
    roomViewModel.getAllFavoriteRooms()
  }

  private var searchTextBinding: Binding<String> {
    Binding(
      get: { roomViewModel.searchText },
      set: { roomViewModel.searchText = $0 })
  }

  @ViewBuilder
  private var roomView: some View {
    if selectedView == ViewOrientation.List {
      favoriteRoomsList
    } else {
      favoriteRoomsGrid
    }
  }

  private var favoriteRoomsGrid: some View {
    ScrollView {
      RoomCardGrid(
        rooms: favoriteRooms,
        isLoading: roomViewModel.isLoading,
        path: $path,
        cardWidth: $cardWidth)
    }
    .shadow(
      color: theme.label.primary.opacity(
        RoomLayoutConstants.cardShadowOpacity),
      radius: RoomLayoutConstants.cardShadowRadius)
  }

  private var favoriteRoomsList: some View {
    List {
      RoomList(
        rooms: favoriteRooms,
        isLoading: roomViewModel.isLoading,
        path: $path,
        rowHeight: $rowHeight)
    }
    .listRowInsets(EdgeInsets())
    .scrollContentBackground(.hidden)
  }
}
