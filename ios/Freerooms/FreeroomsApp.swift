//
//  FreeroomsApp.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import BuildingInteractors
import BuildingModels
import BuildingServices
import BuildingViewModels
import BuildingViews
import CommonUI
import Location
import Persistence
import RoomInteractors
import RoomModels
import RoomServices
import RoomViewModels
import SwiftData
import SwiftUI

// MARK: - FreeroomsApp

@main
struct FreeroomsApp: App {

  // MARK: Lifecycle

  init() {
    Theme.registerFont(named: .ttCommonsPro)
    setFontOnToolbars(.ttCommonsPro)
  }

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      ContentView()
        .preferredColorScheme(.light)
        .environment(theme)
        .environment(\.font, Font.custom(.ttCommonsPro, size: 14))
        .environment(\.buildingViewModel, buildingViewModel)
        .environment(\.roomViewModel, roomViewModel)
    }
  }

  static func makeLiveBuildingViewModel() -> LiveBuildingViewModel {
    let locationManager = LiveLocationManager()
    let locationService = LocationService(locationManager: locationManager)

    let JSONBuildingLoader = LiveJSONBuildingLoader(using: LiveJSONLoader<[DecodableBuilding]>())

    do {
      let schema = Schema([SwiftDataBuilding.self])
      let modelConfiguration = ModelConfiguration(schema: schema)
      let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
      let modelContext = ModelContext(modelContainer)
      let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: modelContext)
      let swiftDataBuildingLoader = LiveSwiftDataBuildingLoader(swiftDataStore: swiftDataStore)

      let buildingLoader = LiveBuildingLoader(
        swiftDataBuildingLoader: swiftDataBuildingLoader,
        JSONBuildingLoader: JSONBuildingLoader)

      let buildingService = LiveBuildingService(buildingLoader: buildingLoader)

      let interactor = BuildingInteractor(buildingService: buildingService, locationService: locationService)

      return LiveBuildingViewModel(interactor: interactor)
    } catch {
      fatalError("Failed to create LiveBuildingViewModel: \(error)")
    }
  }

  static func makeLiveRoomViewModel() -> LiveRoomViewModel {
    let locationManager = LiveLocationManager()
    let locationService = LocationService(locationManager: locationManager)

    let JSONRoomLoader = LiveJSONRoomLoader(using: LiveJSONLoader<[DecodableRoom]>())
    let roomLoader = LiveRoomLoader(JSONBuildingLoader: JSONRoomLoader)
    let roomService = LiveRoomService(roomLoader: roomLoader)

    let interactor = RoomInteractor(roomService: roomService, locationService: locationService)

    // swiftlint:disable:next no_direct_standard_out_logs
    print("Rooms: \(interactor.getAllRoomsSortedAlphabetically(inAscendingOrder: true))")

    return LiveRoomViewModel(interactor: interactor)
  }

  // MARK: Private

  @State private var buildingViewModel = FreeroomsApp.makeLiveBuildingViewModel()
  @State private var roomViewModel = FreeroomsApp.makeLiveRoomViewModel()
  @State private var theme = Theme.light

}
