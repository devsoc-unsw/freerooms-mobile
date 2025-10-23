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
import LocationInteractors
import Networking
import Persistence
import RoomServices
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
        .environment(\.mapViewModel, mapViewModel)
    }
  }

  static func makeLiveBuildingViewModel() -> LiveBuildingViewModel {
    let locationManager = LiveLocationManager()
    let locationService = LiveLocationService(locationManager: locationManager)

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

  static func makeLiveMapViewModel() -> LiveMapViewModel {
    let locationManager = LiveLocationManager()
    let locationService = LiveLocationService(locationManager: locationManager)

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
      let httpClient = URLSessionHTTPClient(session: URLSession.shared)
      // safe unwrapping
      let baseUrl = URL(string: "https://freeroomsstaging.devsoc.app")!
      let liveRoomStatusLoader = LiveRoomStatusLoader(client: httpClient, baseURL: baseUrl)

      let buildingInteractor = BuildingInteractor(
        buildingService: buildingService,
        locationService: locationService,
        roomStatusLoader: liveRoomStatusLoader)
      let locationInteractor = LocationInteractor(locationService: locationService)

      let navigationService = LiveNavigationService()
      let navigationInteractor = LiveNavigationInteractor(nagivationService: navigationService)

      return LiveMapViewModel(
        buildingInteractor: buildingInteractor,
        locationInteractor: locationInteractor,
        navigationInteractor: navigationInteractor)

    } catch {
      fatalError("Failed to create LiveMapViewModel: \(error)")
    }
  }

  // MARK: Private

  @State private var buildingViewModel = FreeroomsApp.makeLiveBuildingViewModel()
  @State private var mapViewModel = FreeroomsApp.makeLiveMapViewModel()

  @State private var theme = Theme.light

}
