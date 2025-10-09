//
//  File.swift
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
    _ roomDestinationBuilderView: @escaping (Room) -> Destination)
  {
    _path = path
    self.roomViewModel = roomViewModel
    self.buildingViewModel = buildingViewModel
    _selectedTab = selectedTab
    self.roomDestinationBuilderView = roomDestinationBuilderView
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      List {
        roomsView(roomViewModel.roomsByBuildingId, buildingViewModel.allBuildings)
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
              // action
            } label: {
              Image(systemName: "list.bullet")
                .resizable()
                .frame(width: 22, height: 15)
            }
          }
          .padding(5)
          .foregroundStyle(theme.label.tertiary)
        }
      }
      .background(Color.gray.opacity(0.1))
//      .padding(.top, 1) 
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
        .onAppear {
          if !roomViewModel.hasLoaded {
            roomViewModel.onAppear()
          }
        }
        .onAppear {
          if !buildingViewModel.hasLoaded {
            buildingViewModel.onAppear()
          }
        }
        .navigationTitle("Rooms")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search...")
    }
    .tabItem {
      Label("Rooms", systemImage: selectedTab == "Rooms" ? "door.left.hand.open" : "door.left.hand.closed")
    }
    .tag("Rooms")
  }

  // MARK: Internal

  @State var roomViewModel: RoomViewModel
  @State var buildingViewModel: BuildingViewModel
  @Binding var selectedTab: String
  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?
  @State var searchText = ""

  func roomsView(
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

  private let roomDestinationBuilderView: (Room) -> Destination

}

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {
  @State var path = NavigationPath()

  var body: some View {
    RoomsTabView<EmptyView>(
      path: $path,
      roomViewModel: PreviewRoomViewModel(),
      buildingViewModel: PreviewBuildingViewModel(),
      selectedTab: .constant("Rooms"))
    { _ in
      EmptyView() // Buildings destination
    }
    .defaultTheme()
  }
}

#Preview {
  PreviewWrapper()
}
