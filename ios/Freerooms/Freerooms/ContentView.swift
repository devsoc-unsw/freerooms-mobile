//
//  ContentView.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import BookingViewModels
import BookingViews
import BuildingModels
import BuildingViewModels
import BuildingViews
import CommonUI
import RoomModels
import RoomViewModels
import RoomViews
import SwiftUI

// MARK: - ContentView

/// No logic, only UI
struct ContentView: View {

  // MARK: Internal

  @Environment(\.buildingViewModel) var buildingViewModel
  @Environment(\.mapViewModel) var mapViewModel
  @Environment(\.roomViewModel) var roomViewModel
  @Environment(TabController.self) var tabController
  @State var selectedRoomsView = ViewOrientation.List
  @State var selectedBuildingsView = ViewOrientation.List

  var body: some View {
    @Bindable var tabController = tabController
    TabView(selection: $tabController.currentTab) {
      BuildingsTabView(path: $buildingPath, selectedView: $selectedBuildingsView) { building in
        RoomsListView(
          building: building,
          path: $buildingPath,
          imageProvider: { BuildingImage[$0] },
          onRefresh: {
            await buildingViewModel.loadNearbyBuildings(to: building)
            await distanceViewModel.reload()
          }) {
            NearbyBuildingsSection(
              nearbyBuildings: buildingViewModel.nearbyBuildingsByBuildingID[building.id] ?? [],
              path: $buildingPath)
          }
          .task { await roomViewModel.onAppear() }
          .task(id: building.id) {
            await buildingViewModel.loadNearbyBuildings(to: building)
            // Refreshes the distances on the room tiles, in case the GPS fix arrived after launch.
            await distanceViewModel.reload()
          }
          .environment(roomViewModel)
      } _: { room in
        roomDetailsView(for: room)
      }
      MapTabView(
        path: $mapPath,
        mapViewModel: mapViewModel,
        roomImageProvider: { roomID in
          RoomImage[roomID]
        },
        roomDestinationBuilder: { room in
          roomDetailsView(for: room)
        })
      RoomsTabView(
        path: $roomPath,
        selectedTab: $tabController.currentTab,
        selectedView: $selectedRoomsView)
      { room in
        roomDetailsView(for: room)
      }
      BookingsTabView()
    }
    .environment(roomViewModel)
    .environment(buildingViewModel)
    // Lets every room and building tile show how far away it is.
    .environment(\.distanceFromUserByBuildingID, distanceViewModel.distanceFromUserByBuildingID)
    .environment(\.distanceFromUserByRoomID, distanceViewModel.distanceFromUserByRoomID)
    .task {
      distanceViewModel.requestLocationPermission()
      await distanceViewModel.keepLocationCurrent()
    }
    .onChange(of: distanceViewModel.userLocation) { _, userLocation in
      buildingViewModel.updateNearestSort(near: userLocation)
    }
    // Distances are worked out from the buildings and rooms the app already has.
    .onChange(of: buildingViewModel.allBuildings, initial: true) {
      distanceViewModel.update(buildings: buildingViewModel.allBuildings)
    }
    .onChange(of: roomViewModel.rooms, initial: true) {
      distanceViewModel.update(rooms: roomViewModel.rooms)
    }
    .onChange(of: scenePhase) { _, newPhase in
      // The location permission prompt and the Settings app make Freerooms inactive.
      // Reload once the user is back, in case they turned location on.
      guard newPhase == .active else { return }
      Task { await distanceViewModel.reload() }
    }
    .tint(theme.accent.primary)
    .preferredColorScheme(theme.preferredColorScheme)
  }

  func roomDetailsView(for room: Room) -> some View {
    RoomDetailsView(room: room)
      .environment(roomViewModel)
      .task(roomViewModel.onAppear)
      .task {
        roomViewModel.clearRoomBookings()
        await roomViewModel.getRoomBookings(roomId: room.id)
      }
  }

  // MARK: Private

  @State private var buildingPath = NavigationPath()
  @State private var mapPath = NavigationPath()
  @State private var roomPath = NavigationPath()

  @Environment(Theme.self) private var theme
  @Environment(LiveDistanceViewModel.self) private var distanceViewModel
  @Environment(\.scenePhase) private var scenePhase
}

extension LiveBuildingViewModel {
  static let preview = PreviewBuildingViewModel()
}

extension LiveBookingViewModel {
  static let preview = PreviewBookingViewModel()
}

extension LiveRoomViewModel {
  static let preview = PreviewRoomViewModel()
}

extension LiveMapViewModel {
  static let preview = PreviewMapViewModel()
}

extension EnvironmentValues {
  @Entry var buildingViewModel: LiveBuildingViewModel = MainActor.assumeIsolated { .preview }
  @Entry var mapViewModel: LiveMapViewModel = MainActor.assumeIsolated { .preview }
  @Entry var roomViewModel: LiveRoomViewModel = MainActor.assumeIsolated { .preview }
}

#Preview {
  ContentView()
    .defaultTheme()
    .environment(TabController())
    .environment(PreviewBookingViewModel() as LiveBookingViewModel)
    .environment(\.buildingViewModel, PreviewBuildingViewModel())
    .environment(PreviewDistanceViewModel() as LiveDistanceViewModel)
    .environment(
      \.mapViewModel,
      MainActor.assumeIsolated {
        PreviewMapViewModel()
      })
    .environment(\.roomViewModel, PreviewRoomViewModel())
}
