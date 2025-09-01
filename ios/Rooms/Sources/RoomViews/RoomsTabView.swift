//
//  File.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - RoomsTabView

public struct RoomsTabView: View {

  // MARK: Lifecycle

  /// init some viewModel to depend on
  public init(viewModel: RoomViewModel) {
    self.viewModel = viewModel
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      List {
        roomsView(viewModel.rooms)
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
      .onAppear(perform: viewModel.onAppear)
      .navigationTitle("Rooms")
      .searchable(text: $searchText, prompt: "Search...")
    }
    .overlay(alignment: .bottom) {
      Button("Rooms in ascending order: \(viewModel.roomsInAscendingOrder)", action: viewModel.getRoomsInOrder)
        .buttonStyle(.borderedProminent)
        .padding(.bottom)
    }
    .tabItem {
      Label("Rooms", systemImage: selectedTab == "Rooms" ? "door.left.hand.open" : "door.left.hand.closed")
    }
    .tag("Rooms")
  }

  // MARK: Internal

  @State var viewModel: RoomViewModel
  @State var selectedTab = "Rooms"
  @State var path = NavigationPath()
  @State var rowHeight: CGFloat?
  @State var searchText = ""

  func roomsView(_ rooms: [Room]) -> some View {
    Section("Building one") {
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
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

}

#Preview {
  RoomsTabView(viewModel: PreviewRoomViewModel())
    .defaultTheme()
}
