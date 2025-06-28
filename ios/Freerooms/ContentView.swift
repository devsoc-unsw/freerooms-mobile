//
//  ContentView.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import Buildings
import CommonUI
import SwiftUI
import Views

// MARK: - Service

/// Source of truth for data
class Service {
  var upperCampusBuildings: [Building] = [
    Building(name: "AGSM", id: "K-E4", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
    Building(name: "Biological Sciences", id: "K-E8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 2),
    Building(name: "Biological Sciences (West)", id: "K-E10", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 3),
    Building(name: "Matthews Building", id: "K-E12", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 4),
  ]

  var middleCampusBuildings: [Building] = [
    Building(name: "AGSM", id: "K-F8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
    Building(name: "Biological Sciences", id: "K-F10", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 2),
    Building(name: "Biological Sciences (West)", id: "K-F12", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 3),
    Building(name: "Matthews Building", id: "K-F13", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 4),
  ]

  func getBuildings() -> (upper: [Building], middle: [Building]) {
    (upperCampusBuildings, middleCampusBuildings)
  }
}

// MARK: - Interactor

/// Performs business logic, we may implement caching in memory at this level to speed up requests
class Interactor {
  let service = Service()

  func getBuildings(inAscendingOrder: Bool) -> (upper: [Building], middle: [Building]) {
    var (upperCampusBuildings, middleCampusBuildings) = service.getBuildings()
    upperCampusBuildings.sort { b1, b2 in
      if inAscendingOrder {
        b1.numberOfAvailableRooms ?? 0 < b2.numberOfAvailableRooms ?? 0
      } else {
        b1.numberOfAvailableRooms ?? 0 > b2.numberOfAvailableRooms ?? 0
      }
    }
    middleCampusBuildings.sort { b1, b2 in
      if inAscendingOrder {
        b1.numberOfAvailableRooms ?? 0 < b2.numberOfAvailableRooms ?? 0
      } else {
        b1.numberOfAvailableRooms ?? 0 > b2.numberOfAvailableRooms ?? 0
      }
    }
    return (upperCampusBuildings, middleCampusBuildings)
  }
}

// MARK: - ViewModel

/// Provides formatted data to views and forwards commands from views to relevant interactors
@Observable
class ViewModel {
  let interactor = Interactor()

  var upperCampusBuildings: [Building] = []

  var middleCampusBuildings: [Building] = []

  var buildingsInAscendingOrder = true

  var isLoading = false

  func getBuildingsInOrder() {
    isLoading = true
    buildingsInAscendingOrder.toggle()
    (upperCampusBuildings, middleCampusBuildings) = interactor.getBuildings(inAscendingOrder: buildingsInAscendingOrder)

    // Simulate delay from fetching buildings
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }

      isLoading = false
    }
  }

  func onAppear() {
    (upperCampusBuildings, middleCampusBuildings) = interactor.getBuildings(inAscendingOrder: true)
  }
}

// MARK: - Room

struct Room: Hashable {
  let name: String
}

// MARK: - ContentView

/// No logic, only UI
struct ContentView: View {

  // MARK: Internal

  @State var viewModel = ViewModel()
  @State var path = NavigationPath()
  @State var selectedTab = "Buildings"
  @State var rowHeight: CGFloat?

  var body: some View {
    TabView(selection: $selectedTab) {
      buildingsTab

      roomsTab
    }
    .tint(theme.accent.primary)
  }

  var buildingsTab: some View {
    NavigationStack(path: $path) {
      List {
        buildingsView(for: "Upper campus", from: viewModel.upperCampusBuildings)

        buildingsView(for: "Middle campus", from: viewModel.middleCampusBuildings)
      }
      .listRowInsets(EdgeInsets()) // Removes the large default padding around a list
      .scrollContentBackground(.hidden) // Hides default grey background of the list to allow shadow to appear correctly under section cards
      .shadow(
        color: theme.label.primary.opacity(0.2),
        radius: 5) // Adds a shadow to section cards (and also the section header but thankfully it's not noticeable)
      .navigationDestination(for: Building.self) { building in
        // Renders the view for displaying a building that has been clicked on
        Button {
          path.append(Room(name: "bruh"))
        } label: {
          Text("bruh")
        }
        .navigationTitle(building.name)
        .navigationBarTitleDisplayMode(.inline)
      }
      .navigationDestination(for: Room.self) { room in // Renders the view for displaying a room that has been clicked on
        Text(room.name)
          .navigationTitle(room.name)
      }
      .opacity(
        viewModel
          .isLoading
          ? 0
          : 1) // This hides a glitch where the bottom border of top section row and vice versa flashes when changing order
        .onAppear(perform: viewModel.onAppear)
        .navigationTitle("Buildings")
    }
    .overlay(alignment: .bottom) {
      Button("Buildings in ascending order: \(viewModel.buildingsInAscendingOrder)", action: viewModel.getBuildingsInOrder)
        .buttonStyle(.borderedProminent)
        .padding(.bottom)
    }
    .tabItem {
      Label("Buildings", systemImage: "building")
    }
    .tag("Buildings") // Sets the selected tab to "Buildings"
  }

  var roomsTab: some View {
    Text("Rooms tab")
      .tabItem {
        Label("Rooms", systemImage: selectedTab == "Rooms" ? "door.left.hand.open" : "door.left.hand.closed")
      }
      .tag("Rooms")
  }

  func buildingsView(for campus: String, from buildings: [Building]) -> some View {
    Section {
      ForEach(buildings) { building in
        BuildingListRowView(path: $path, rowHeight: $rowHeight, building: building, buildings: buildings)
          .padding(.vertical, 5)
      }
    } header: {
      Text(campus)
        .foregroundStyle(theme.label.primary)
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

}

// MARK: - BuildingListRowView

struct BuildingListRowView: View {
  private struct HeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(
      value _: inout CGFloat,
      nextValue _: () -> CGFloat)
    { }
  }

  @Environment(Theme.self) private var theme

  @Binding var path: NavigationPath
  @Binding var rowHeight: CGFloat?
  let building: Building
  let buildings: [Building]
  var index: Int {
    buildings.firstIndex(of: building)!
  }

  var body: some View {
    Button {
      path.append(building)
    } label: {
      HStack(spacing: 0) {
        BuildingImage[building.id]
          .resizable()
          .frame(width: rowHeight, height: rowHeight) // This image matches the height of the below HStack
          .clipShape(RoundedRectangle(cornerRadius: 5))
          .padding(.trailing)

        HStack(spacing: 0) {
          VStack(alignment: .leading) {
            Text(building.name)
              .bold()
              .foregroundStyle(theme.label.primary)
              .lineLimit(1)
              .truncationMode(.tail)

            // The `^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true)` handles plurals using "automatic grammar agreement", works for a couple languages
            Text("^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true) available")
          }

          Spacer()

          Text("4.9")
          Image(systemName: "star.fill")
            .foregroundStyle(theme.yellow)
            .padding(.trailing)

          Image(systemName: "chevron.right")
        }
        .background(GeometryReader { geometry in // In a background the GeometryReader expands to the bounds of the foreground view
          Color.clear.preference(
            key: HeightPreferenceKey.self, // This saves the height into the HeightPreferenceKey
            value: geometry.size.height)
        })
      }
      .foregroundStyle(theme.label.secondary) // Applies to everything in child views unless overridden
    }
    .listRowBackground(
      RoundedRectangle(cornerRadius: 10)
        .fill(.background)
        .strokeBorder(LinearGradient(
          colors: [
            theme.accent.primary.opacity(1 - Double(buildings.count - index) / Double(buildings.count * 2)),
            theme.accent.primary.opacity(1 - Double(buildings.count - index - 1) / Double(buildings.count * 2)),
          ],
          startPoint: .top,
          endPoint: .bottom))
        .padding(.top, building == buildings.first ? 0 : -10) // Hide the top padding on the row unless this is the first row
        .padding(
          .bottom,
          building == buildings.last ? 0 : -10) // Hide the bottom padding on the row unless this is the last row
    )
    .onPreferenceChange(HeightPreferenceKey.self) {
      rowHeight = $0 // This value comes from the HStack above
    }
  }
}

#Preview {
  ContentView()
    .defaultTheme()
}
