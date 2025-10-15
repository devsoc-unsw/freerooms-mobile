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
    /// Sets searchable cancel button to orange
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor(Theme.light.accent.primary)
  }

  // MARK: Internal

  static var sharedContainer: ModelContainer = {
    let schema = Schema([SwiftDataBuilding.self, SwiftDataRoom.self])
    let config = ModelConfiguration(schema: schema)
    return try! ModelContainer(for: schema, configurations: [config])
  }()

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
      let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: FreeroomsApp.sharedContainer.mainContext)
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

  static func makeLiveRoomViewModel() -> LiveRoomViewModel {
    let locationManager = LiveLocationManager()
    let locationService = LiveLocationService(locationManager: locationManager)

    let JSONRoomLoader = LiveJSONRoomLoader(using: LiveJSONLoader<[DecodableRoom]>())

    let httpClient = URLSessionHTTPClient(session: URLSession.shared)

    /// TODO: baseURL should be in env variables
    guard let baseURL = URL(string: "https://freeroomsstaging.devsoc.app") else {
      fatalError("Invalid base url")
    }

    do {
      let swiftDataStore = try SwiftDataStore<SwiftDataRoom>(modelContext: FreeroomsApp.sharedContainer.mainContext)
      let swiftDataRoomLoader = LiveSwiftDataRoomLoader(swiftDataStore: swiftDataStore)

      let roomStatusLoader = LiveRoomStatusLoader(client: httpClient, baseURL: baseURL)

      let roomLoader = LiveRoomLoader(JSONRoomLoader: JSONRoomLoader, roomStatusLoader: roomStatusLoader)

      let remoteBookingLoader = LiveRemoteRoomBookingLoader(client: httpClient, baseURL: baseURL)
      let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: remoteBookingLoader)

      let roomService = LiveRoomService(roomLoader: roomLoader, roomBookingLoader: roomBookingLoader)

      let interactor = RoomInteractor(roomService: roomService, locationService: locationService)

      return LiveRoomViewModel(interactor: interactor)
    } catch {
      fatalError("Failed to create LiveBuildingViewModel: \(error)")
    }
  }

  // MARK: Private

  @State private var buildingViewModel = FreeroomsApp.makeLiveBuildingViewModel()
  @State private var roomViewModel = FreeroomsApp.makeLiveRoomViewModel()
  @State private var theme = Theme.light

}
