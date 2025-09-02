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

public struct RoomsTabView: View {

  // MARK: Lifecycle

  /// init some viewModel to depend on
  public init(roomViewModel: RoomViewModel, buildingViewModel: BuildingViewModel) {
    self.roomViewModel = roomViewModel
    self.buildingViewModel = buildingViewModel
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      List {
        roomsView(roomViewModel.rooms, buildingViewModel.buildings)
      }
      .background(Color.gray.opacity(0.1))
      .padding(.top, 1)
      .listRowInsets(EdgeInsets()) // Removes the large default padding around a list
      .scrollContentBackground(.hidden) // Hides default grey background of the list to allow shadow to appear correctly under section cards
      .shadow(
        color: theme.label.primary.opacity(0.2),
        radius: 5) // Adds a shadow to section cards (and also the section header but thankfully it's not noticeable)
      .navigationDestination(for: Room.self) { room in
        // Renders the view for displaying a building that has been clicked on
        Button {
          path.append(Room.exampleOne)
        } label: {
          Text("bruh test test")
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
      }
      .opacity(
        roomViewModel.isLoading
          ? 0
          : 1) // This hides a glitch where the bottom border of top section row and vice versa flashes when changing order
        .onAppear(perform: roomViewModel.onAppear)
        .onAppear(perform: buildingViewModel.onAppear)
        .navigationTitle("Rooms")
        .searchable(text: $searchText, prompt: "Search...")
    }
    .overlay(alignment: .bottom) {
      Button("Rooms in ascending order: \(roomViewModel.roomsInAscendingOrder)", action: roomViewModel.getRoomsInOrder)
        .buttonStyle(.borderedProminent)
        .padding(.bottom)
    }
    .tabItem {
      Label("Rooms", systemImage: selectedTab == "Rooms" ? "door.left.hand.open" : "door.left.hand.closed")
    }
    .tag("Rooms")
  }

  // MARK: Internal

  @State var roomViewModel: RoomViewModel
  @State var buildingViewModel: BuildingViewModel
  @State var selectedTab = "Rooms"
  @State var path = NavigationPath()
  @State var rowHeight: CGFloat?
  @State var searchText = ""

  func roomsView(_ rooms: [Room], _ buildings: [Building]) -> some View {
    ForEach(buildings) { building in
      Section {
        ForEach(rooms) { room in
          if room.buildingId == building.id {
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
        }
      } header: {
        Text(building.name)
          .foregroundStyle(theme.label.primary)
      }
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

}

#Preview {
  RoomsTabView(roomViewModel: PreviewRoomViewModel(), buildingViewModel: PreviewBuildingViewModel())
    .defaultTheme()
}
