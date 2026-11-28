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
import BuildingServices
import CommonUI
import FreeroomsNavigation
import OSLog
import RoomModels
import RoomViewModels
import RoomViews
import SwiftUI
import VISOR
import VISORObservation

/// The root view for the application
///
/// There should only be one ``ContentView`` per `Scene`.
/// This `View` manages the
struct ContentView: View {

  // MARK: Internal
  
  init(services: FreeroomsServices) {
    
    // MARK: ViewModel Factory setup
    
    buildingViewModelFactory = .routed { (router: Scene.Router) in
      return BuildingsViewModel(
        router: router,
        buildingService: services.buildingService)
    }
    
    bookingViewModelFactory = .routed { (router: Scene.Router) in
      return BookingViewModel(router: router)
    }
    
  }

  var body: some View {
    RouterHost(
      router: router,
      pushContent: pushContent(for:),
      sheetContent: sheetContent(for:),
      fullScreenContent: fullScreenContent(for:))
    {
      TabView(selection: $router.selectedRoot) {
        BuildingsTabView(contentBuilder: contentBuilder)
          .tabItem {
            Label("Buildings", systemImage: "building")
          }
          .tag(FreeroomsTab.buildings)
        Text("Map")
          .tabItem {
            Label("Map", systemImage: "map")
          }
          .tag(FreeroomsTab.map)
        Text("Rooms")
          .tabItem {
            Label(
              "Rooms",
              systemImage: router.selectedRoot == .rooms
                ? "door.left.hand.open"
                : "door.left.hand.closed")
          }
          .tag(FreeroomsTab.rooms)
        BookingsTabView(contentBuilder: contentBuilder)
          .tabItem {
            Label("Bookings", systemImage: "book.pages")
          }
          .tag(FreeroomsTab.bookings)
      }
    }
    .environment(bookingViewModelFactory)
    .environment(buildingViewModelFactory)
  }

  // MARK: Private

  // MARK: Content Handlers

  private typealias Scene = FreeroomsNavigationScene

  @State private var router = FreeroomsNavigationScene.Router(
    logger: Logger(subsystem: "app.devsoc.Freerooms", category: "Router"))

  @ViewBuilder
  private func pushContent(for _: Scene.Push) -> some View {
    sceneNotImplemented(forType: "Push")
  }

  @ViewBuilder
  private func sheetContent(for _: Scene.Sheet) -> some View {
    sceneNotImplemented(forType: "Sheet")
  }

  @ViewBuilder
  private func fullScreenContent(for _: Scene.FullScreen) -> some View {
    sceneNotImplemented(forType: "FullScreen")
  }
  
  private var contentBuilder: some FreeroomsContentBuilderProtocol {
    FreeroomsContentBuilder(
      pushContent: pushContent(for:),
      sheetContent: sheetContent(for:),
      fullScreenContent: fullScreenContent(for:))
  }

  private func sceneNotImplemented(
    forType type: StaticString,
    file: StaticString = #file,
    line: UInt = #line)
    -> Never
  {
    preconditionFailure("Scene type \(type) not implemented.", file: file, line: line)
  }
  
  // MARK: ViewModel Factories
  
  let buildingViewModelFactory: BuildingsViewModel.Factory
  let bookingViewModelFactory: BookingViewModel.Factory

}

//#Preview {
//  ContentView()
//}

// // MARK: - ContentView
//
// /// No logic, only UI
// struct ContentView: View {
//
//  // MARK: Internal
//
//  @Environment(\.buildingViewModel) var buildingViewModel
//  @Environment(\.mapViewModel) var mapViewModel
//  @Environment(\.roomViewModel) var roomViewModel
//  @Environment(TabController.self) var tabController
//  @State var selectedRoomsView = ViewOrientation.List
//  @State var selectedBuildingsView = ViewOrientation.List
//
//  var body: some View {
//    @Bindable var tabController = tabController
//    TabView(selection: $tabController.currentTab) {
//      BuildingsTabView(path: $buildingPath, selectedView: $selectedBuildingsView) { building in
//        RoomsListView(building: building, path: $buildingPath, imageProvider: {
//          BuildingImage[$0]
//        })
//        .task { await roomViewModel.onAppear() }
//        .environment(roomViewModel)
//      } _: { room in
//        roomDetailsView(for: room)
//      }
//      .tag(FreeroomsTab.buildings)
//      MapTabView(
//        path: $mapPath,
//        mapViewModel: mapViewModel,
//        roomImageProvider: { roomID in
//          RoomImage[roomID]
//        },
//        roomDestinationBuilder: { room in
//          roomDetailsView(for: room)
//        })
//        .tag(FreeroomsTab.map)
//      RoomsTabView(
//        path: $roomPath,
//        selectedTab: $tabController.currentTab,
//        selectedView: $selectedRoomsView)
//      { room in
//        roomDetailsView(for: room)
//      }
//      .tag(FreeroomsTab.rooms)
//      BookingsTabView()
//        .tag(FreeroomsTab.bookings)
//    }
//    .environment(roomViewModel)
//    .environment(buildingViewModel)
//    .tint(theme.accent.primary)
//    .preferredColorScheme(theme.preferredColorScheme)
//  }
//
//  func roomDetailsView(for room: Room) -> some View {
//    RoomDetailsView(room: room)
//      .environment(roomViewModel)
//      .task(roomViewModel.onAppear)
//      .task {
//        roomViewModel.clearRoomBookings()
//        await roomViewModel.getRoomBookings(roomId: room.id)
//      }
//  }
//
//  // MARK: Private
//
//  @State private var buildingPath = NavigationPath()
//  @State private var mapPath = NavigationPath()
//  @State private var roomPath = NavigationPath()
//
//  @Environment(Theme.self) private var theme
// }
//
// extension LiveBuildingViewModel {
//  static let preview = PreviewBuildingViewModel()
// }
//
// extension LiveBookingViewModel {
//  static let preview = PreviewBookingViewModel()
// }
//
// extension LiveRoomViewModel {
//  static let preview = PreviewRoomViewModel()
// }
//
// extension LiveMapViewModel {
//  static let preview = PreviewMapViewModel()
// }
//
// extension EnvironmentValues {
//  @Entry var buildingViewModel: LiveBuildingViewModel = MainActor.assumeIsolated { .preview }
//  @Entry var mapViewModel: LiveMapViewModel = MainActor.assumeIsolated { .preview }
//  @Entry var roomViewModel: LiveRoomViewModel = MainActor.assumeIsolated { .preview }
// }
//
// #Preview {
//  ContentView()
//    .defaultTheme()
//    .environment(TabController())
//    .environment(PreviewBookingViewModel() as LiveBookingViewModel)
//    .environment(\.buildingViewModel, PreviewBuildingViewModel())
//    .environment(
//      \.mapViewModel,
//      MainActor.assumeIsolated {
//        PreviewMapViewModel()
//      })
//    .environment(\.roomViewModel, PreviewRoomViewModel())
// }
//
