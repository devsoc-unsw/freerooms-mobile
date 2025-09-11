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
import Foundation
import Location
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
        .environment(\.buildingViewModel, viewModel)
    }
  }

  static func makeLiveBuildingViewModel() -> LiveBuildingViewModel {
    let locationManager = LiveLocationManager()
    let locationService = LiveLocationService(locationManager: locationManager)

    let JSONBuildingLoader = LiveJSONBuildingLoader(using: LiveJSONLoader<[DecodableBuilding]>())

    let httpClient = URLSessionHTTPClient(session: URLSession.shared)

    /// TODO: baseURL should be in env variables
    guard let baseURL = URL(string: "https://freeroomsstaging.devsoc.app") else {
      fatalError("Invalid base url")
    }

    guard let baseURLREAL = URL(string: "https://freerooms.devsoc.app/") else {
      fatalError("Invalid base url")
    }

    do {
      let schema = Schema([SwiftDataBuilding.self])
      let modelConfiguration = ModelConfiguration(schema: schema)
      let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
      let modelContext = ModelContext(modelContainer)
      let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: modelContext)
      let swiftDataBuildingLoader = LiveSwiftDataBuildingLoader(swiftDataStore: swiftDataStore)

      let roomStatusLoader = LiveRoomStatusLoader(client: httpClient, baseURL: baseURL)
      let buildingRatingLoader = RemoteBuildingRatingLoader(client: httpClient, baseURL: baseURLREAL)

      let buildingLoader = LiveBuildingLoader(
        swiftDataBuildingLoader: swiftDataBuildingLoader,
        JSONBuildingLoader: JSONBuildingLoader, roomStatusLoader: roomStatusLoader, buildingRatingLoader: buildingRatingLoader)

      let buildingService = LiveBuildingService(buildingLoader: buildingLoader)

      let interactor = BuildingInteractor(buildingService: buildingService, locationService: locationService)

      return LiveBuildingViewModel(interactor: interactor)
    } catch {
      fatalError("Failed to create LiveBuildingViewModel: \(error)")
    }
  }

  // MARK: Private

  @State private var viewModel = FreeroomsApp.makeLiveBuildingViewModel()

  @State private var theme = Theme.light

}
