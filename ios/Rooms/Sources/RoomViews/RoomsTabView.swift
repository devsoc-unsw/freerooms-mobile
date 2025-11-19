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
    roomViewModel: RoomViewModel,
    buildingViewModel: BuildingViewModel,
    selectedTab: Binding<String>,
    selectedView: Binding<RoomOrientation>,
    _ roomDestinationBuilderView: @escaping (Room) -> Destination)
  {
    _path = path
    self.roomViewModel = roomViewModel
    self.buildingViewModel = buildingViewModel
    _selectedTab = selectedTab
    _selectedView = selectedView
    self.roomDestinationBuilderView = roomDestinationBuilderView
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      roomView
        .refreshable {
          Task {
            await roomViewModel.reloadRooms()
          }
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
                roomViewModel.getRoomsInOrder()
              } label: {
                Image(systemName: "arrow.up.arrow.down")
                  .resizable()
                  .frame(width: 25, height: 20)
              }

              Button {
                if selectedView == RoomOrientation.Card {
                  selectedView = RoomOrientation.List
                } else {
                  selectedView = RoomOrientation.Card
                }
              } label: {
                Image(systemName: selectedView == RoomOrientation.List ? "square.grid.2x2" : "list.bullet")
                  .resizable()
                  .frame(width: 22, height: 20)
              }
            }
            .padding(5)
            .foregroundStyle(theme.label.tertiary)
          }
        }
        .background(Color.gray.opacity(0.1))
        .listRowInsets(EdgeInsets()) // Removes the large default padding around a list
        .scrollContentBackground(.hidden) // Hides default grey background of the list to allow shadow to appear correctly under section cards
        .shadow(
          color: theme.label.primary.opacity(0.2),
          radius: 5) // Adds a shadow to section cards (and also the section header but thankfully it's not noticeable)
        .navigationDestination(for: Room.self) { room in
          roomDestinationBuilderView(room)
        }
        .opacity(
          roomViewModel.isLoading
            ? 0
            : 1) // This hides a glitch where the bottom border of top section row and vice versa flashes when changing order
          .task {
            if !roomViewModel.hasLoaded {
              await roomViewModel.onAppear()
            }
          }
          .alert(item: $roomViewModel.loadRoomErrorMessage) { error in
            Alert(
              title: Text(error.title),
              message: Text(error.message),
              dismissButton: .default(Text("OK")))
          }
          .navigationTitle("Rooms")
          .searchable(text: $roomViewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
    }
    .tabItem {
      Label("Rooms", systemImage: selectedTab == "Rooms" ? "door.left.hand.open" : "door.left.hand.closed")
    }
    .tag("Rooms")
  }

  // MARK: Internal

  @State var buildingViewModel: BuildingViewModel
  @Binding var selectedTab: String

  @Binding var selectedView: RoomOrientation
  @State var cardWidth: CGFloat?
  @State var searchText = ""
  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?

  @State var roomViewModel: RoomViewModel

  // search text is owned by the view model

  func roomsCardView(
    _ roomsByBuildingId: [String: [Room]],
    _ buildings: [Building])
    -> some View
  {
    ForEach(buildings) { building in
      let rooms = roomsByBuildingId[building.id] ?? []
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
    _ roomsByBuildingId: [String: [Room]],
    _ buildings: [Building])
    -> some View
  {
    ForEach(buildings) { building in
      let rooms = roomsByBuildingId[building.id] ?? []
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
            .foregroundStyle(theme.label.primary)
        }
      }
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  private let roomDestinationBuilderView: (Room) -> Destination

  @ViewBuilder
  private var roomView: some View {
    if selectedView == RoomOrientation.List {
      List {
        roomsListView(roomViewModel.filteredRoomsByBuildingId, buildingViewModel.allBuildings)
      }
    } else {
      ScrollView {
        roomsCardView(roomViewModel.filteredRoomsByBuildingId, buildingViewModel.allBuildings)
      }
    }
  }

}

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {
  @State var path = NavigationPath()
  @State var selectedView = RoomOrientation.List

  var body: some View {
    RoomsTabView<EmptyView>(
      path: $path,
      roomViewModel: PreviewRoomViewModel(),
      buildingViewModel: PreviewBuildingViewModel(),
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
