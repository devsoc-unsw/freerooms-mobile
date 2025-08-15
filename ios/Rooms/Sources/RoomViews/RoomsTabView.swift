//
//  File.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

import CommonUI
import RoomModels
import SwiftUI

// MARK: - RoomsTabView

public struct RoomsTabView: View {

  // MARK: Lifecycle

  /// init some viewModel to depend on
  public init() { }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      List {
        Section {
          ForEach(rooms) { room in
            GenericListRowView<Room>(
              path: $path,
              rowHeight: $rowHeight,
              item: room,
              items: rooms,
              bundle: .module)
              .padding(.vertical, 5)
          }
        }
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
          path.append(Room(
            name: "Ainsworth 101",
            id: "K-B16",
            abbreviation: "A-101",
            capacity: 10,
            usage: "Goon",
            school: "UNSW"))
        } label: {
          Text("bruh test test")
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
      }
      .navigationTitle("Rooms")
      .searchable(text: $searchText, prompt: "Search...")
    }
    .tabItem {
      Label("Rooms", systemImage: selectedTab == "Rooms" ? "door.left.hand.open" : "door.left.hand.closed")
    }
    .tag("Rooms")
  }

  // MARK: Internal

  @State var selectedTab = "Buildings"
  @State var path = NavigationPath()
  @State var rowHeight: CGFloat?
  @State var searchText = ""

  let rooms: [Room] = [
    Room(name: "Ainsworth 101", id: "K-B16", abbreviation: "A-101", capacity: 10, usage: "Goon", school: "UNSW"),
    Room(name: "Ainsworth 201", id: "K-C20", abbreviation: "A-201", capacity: 10, usage: "Goon", school: "UNSW"),
    Room(name: "Ainsworth 301", id: "K-B16", abbreviation: "A-201", capacity: 10, usage: "Goon", school: "UNSW"),
    Room(name: "Ainsworth 401", id: "K-B16", abbreviation: "A-201", capacity: 10, usage: "Goon", school: "UNSW"),
    Room(name: "Ainsworth 501", id: "K-B16", abbreviation: "A-201", capacity: 10, usage: "Goon", school: "UNSW"),
  ]

  // MARK: Private

  @Environment(Theme.self) private var theme

}

#Preview {
  RoomsTabView()
    .defaultTheme()
}
