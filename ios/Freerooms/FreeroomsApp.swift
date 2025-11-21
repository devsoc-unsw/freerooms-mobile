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
import LocationInteractors
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
        .environment(\.mapViewModel, mapViewModel)
        .environment(\.roomViewModel, roomViewModel)
        .environment(buildingViewModel)
        .environment(mapViewModel)
        .environment(roomViewModel)
    }
  }

  static func makeLiveBuildingViewModel() -> LiveBuildingViewModel {
    let locationService = makeLocationService()
    let JSONBuildingLoader = LiveJSONBuildingLoader(using: LiveJSONLoader<[DecodableBuilding]>())

    do {
      let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: FreeroomsApp.sharedContainer.mainContext)
      let swiftDataBuildingLoader = LiveSwiftDataBuildingLoader(swiftDataStore: swiftDataStore)

      let (roomStatusLoader, buildingRatingLoader, _) = makeRemoteLoaders()

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

  static func makeLiveMapViewModel() -> LiveMapViewModel {
    let locationService = makeLocationService()

    let JSONBuildingLoader = LiveJSONBuildingLoader(using: LiveJSONLoader<[DecodableBuilding]>())

    do {
      let schema = Schema([SwiftDataBuilding.self])
      let modelConfiguration = ModelConfiguration(schema: schema)
      let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
      let modelContext = ModelContext(modelContainer)
      let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: modelContext)
      let swiftDataBuildingLoader = LiveSwiftDataBuildingLoader(swiftDataStore: swiftDataStore)

      let (roomStatusLoader, buildingRatingLoader, _) = makeRemoteLoaders()

      let buildingLoader = LiveBuildingLoader(
        swiftDataBuildingLoader: swiftDataBuildingLoader,
        JSONBuildingLoader: JSONBuildingLoader,
        roomStatusLoader: roomStatusLoader,
        buildingRatingLoader: buildingRatingLoader)

      let buildingService = LiveBuildingService(buildingLoader: buildingLoader)
      let buildingInteractor = BuildingInteractor(
        buildingService: buildingService,
        locationService: locationService)
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

  static func makeLiveRoomViewModel() -> LiveRoomViewModel {
    let locationManager = LiveLocationManager()
    let locationService = LiveLocationService(locationManager: locationManager)

    let JSONRoomLoader = LiveJSONRoomLoader(using: LiveJSONLoader<[DecodableRoom]>())

    do {
      // TODO: ignore unused warning, swiftDataStore is not implemented
      let swiftDataStore = try SwiftDataStore<SwiftDataRoom>(modelContext: FreeroomsApp.sharedContainer.mainContext)
      let swiftDataRoomLoader = LiveSwiftDataRoomLoader(swiftDataStore: swiftDataStore)

      let (roomStatusLoader, _, remoteBookingLoader) = makeRemoteLoaders()

      let roomLoader = LiveRoomLoader(
        JSONRoomLoader: JSONRoomLoader,
        roomStatusLoader: roomStatusLoader,
        swiftDataRoomLoader: swiftDataRoomLoader)

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
  @State private var mapViewModel = FreeroomsApp.makeLiveMapViewModel()

  @State private var roomViewModel = FreeroomsApp.makeLiveRoomViewModel()
  @State private var theme = Theme.light

  private static func makeLocationService() -> LiveLocationService {
    let locationManager = LiveLocationManager()
    return LiveLocationService(locationManager: locationManager)
  }

  private static func makeHTTPClient() -> URLSessionHTTPClient {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 5
    configuration.timeoutIntervalForResource = 5
    configuration.waitsForConnectivity = false

    let session = URLSession(configuration: configuration)
    return URLSessionHTTPClient(session: session)
  }

  private static func makeBaseURLs() -> (staging: URL, production: URL) {
    guard let staging = URL(string: "https://freeroomsstaging.devsoc.app") else {
      fatalError("Invalid staging base URL")
    }
    guard let production = URL(string: "https://freerooms.devsoc.app/") else {
      fatalError("Invalid production base URL")
    }
    return (staging, production)
  }

  private static func makeRemoteLoaders()
    -> (
      roomStatusLoader: LiveRoomStatusLoader,
      buildingRatingLoader: RemoteBuildingRatingLoader,
      remoteBookingLoader: LiveRemoteRoomBookingLoader)
  {
    let httpClient = makeHTTPClient()
    let (stagingURL, productionURL) = makeBaseURLs()

    let roomStatusLoader = LiveRoomStatusLoader(client: httpClient, baseURL: stagingURL)
    let buildingRatingLoader = RemoteBuildingRatingLoader(client: httpClient, baseURL: productionURL)
    let remoteBookingLoader = LiveRemoteRoomBookingLoader(client: httpClient, baseURL: productionURL)

    return (roomStatusLoader, buildingRatingLoader, remoteBookingLoader)
  }
}
