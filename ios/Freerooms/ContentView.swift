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

  func getBuildingsInOrder() {
    buildingsInAscendingOrder.toggle()
    (upperCampusBuildings, middleCampusBuildings) = interactor.getBuildings(inAscendingOrder: buildingsInAscendingOrder)
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
  @Environment(Theme.self) private var theme

  @State var viewModel = ViewModel()
  @State var path = NavigationPath()
  @State var selectedTab = "Buildings"

  var body: some View {
    TabView(selection: $selectedTab) {
      buildingsTab

      roomsTab
    }
    .tint(theme.accent.primary)
  }

  var buildingsTab: some View {
    NavigationStack(path: $path) {
      Button("Buildings in ascending order: \(viewModel.buildingsInAscendingOrder)", action: viewModel.getBuildingsInOrder)
      List {
        buildingsView(for: "Upper campus", from: viewModel.upperCampusBuildings)

        buildingsView(for: "Middle campus", from: viewModel.middleCampusBuildings)
      }
      .listRowInsets(EdgeInsets()) // Removes the large default padding around a list
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
      .onAppear {
        viewModel.onAppear()
      }
      .navigationTitle("Buildings")
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
        buildingView(for: building, in: buildings)
      }
    } header: {
      Text(campus)
        .foregroundStyle(theme.label.primary)
    }
  }

  func buildingView(for building: Building, in buildings: [Building]) -> some View {
    Button {
      path.append(building)
    } label: {
      HStack(spacing: 0) {
        BuildingImage[building.id]
          .resizable()
          .aspectRatio(contentMode: .fill) // All building images should occupy the same frame
          .frame(width: 40, height: 40)
          .clipShape(RoundedRectangle(cornerRadius: 5))
          .padding(.trailing)

        VStack {
          HStack(spacing: 0) {
            VStack(alignment: .leading) {
              Text(building.name)
                .bold()
                .foregroundStyle(theme.label.primary)

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
        }
      }
      .foregroundStyle(theme.label.secondary) // Applies to everything in child views unless overridden
    }
    .listRowBackground(
      RoundedRectangle(cornerRadius: 10)
        .fill(.background)
        .strokeBorder(theme.accent.secondary)
        .padding(.top, building == buildings.first ? 0 : -10) // Hide the top padding on the row unless this is the first row
        .padding(
          .bottom,
          building == buildings.last ? 0 : -10) // Hide the bottom padding on the row unless this is the last row
    )
  }
}

#Preview {
  // Modify large navigation title
  let largeTitlePointSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
  var largeTitleFont = UIFont(name: .ttCommonsPro, size: largeTitlePointSize)
  if let largeTitleBoldFontDescriptor = largeTitleFont?.fontDescriptor.withSymbolicTraits(.traitBold) {
    largeTitleFont = UIFont(descriptor: largeTitleBoldFontDescriptor, size: largeTitlePointSize) // Make it bold
  }
  let largeTitleTextAttributes = [
    NSAttributedString.Key.font: largeTitleFont as Any,
    NSAttributedString.Key.foregroundColor: UIColor(Theme.light.label.primary),
  ]
  UINavigationBar.appearance().largeTitleTextAttributes = largeTitleTextAttributes

  // Modify regular navigation title
  let titlePointSize = UIFont.preferredFont(forTextStyle: .body).pointSize
  var titleFont = UIFont(name: .ttCommonsPro, size: titlePointSize)
  if let titleBoldFontDescriptor = titleFont?.fontDescriptor.withSymbolicTraits(.traitBold) {
    titleFont = UIFont(descriptor: titleBoldFontDescriptor, size: titlePointSize) // Make it bold
  }
  let titleTextAttributes = [
    NSAttributedString.Key.font: titleFont as Any,
    NSAttributedString.Key.foregroundColor: UIColor(Theme.light.label.primary),
  ]
  UINavigationBar.appearance().titleTextAttributes = titleTextAttributes

  // Modify tab bar item labels
  UITabBarItem.appearance().setTitleTextAttributes(
    [.font: UIFont(name: .ttCommonsPro, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize) as Any],
    for: .normal)
  return ContentView()
    .defaultTheme()
}
