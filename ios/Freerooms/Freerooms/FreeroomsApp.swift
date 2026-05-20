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
    }
  }

  // MARK: Private

  @State private var buildingViewModel: LiveBuildingViewModel
  @State private var mapViewModel: LiveMapViewModel
  @State private var roomViewModel: LiveRoomViewModel
  @State private var theme = Theme.light

  init() {
      // UI setup
      Theme.registerFont(named: .ttCommonsPro)
      setFontOnToolbars(.ttCommonsPro)
      UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor(Theme.light.accent.primary)

      // Shared infrastructure
      let locationService = FreeroomsApp.makeLocationService()
      let httpClient = FreeroomsApp.makeHTTPClient()
      let (stagingURL, productionURL) = FreeroomsApp.makeBaseURLs()
      let (roomStatusLoader, buildingRatingLoader, remoteBookingLoader, roomRatingLoader, roomFilterLoader) = FreeroomsApp.makeRemoteLoaders()

      // Shared interactors
      let buildingInteractor = FreeroomsApp.makeBuildingInteractor(
        locationService: locationService,
        roomStatusLoader: roomStatusLoader,
        buildingRatingLoader: buildingRatingLoader
      )
      let roomInteractor = FreeroomsApp.makeRoomInteractor(
        locationService: locationService,
        roomStatusLoader: roomStatusLoader,
        remoteBookingLoader: remoteBookingLoader,
        roomRatingLoader: roomRatingLoader,
        roomFilterLoader: roomFilterLoader
      )

      _buildingViewModel = State(initialValue: LiveBuildingViewModel(interactor: buildingInteractor))
      _roomViewModel = State(initialValue: LiveRoomViewModel(interactor: roomInteractor))
      _mapViewModel = State(initialValue: FreeroomsApp.makeMapViewModel(
        buildingInteractor: buildingInteractor,
        roomInteractor: roomInteractor,
        locationService: locationService
      ))
    }

  // MARK: - Factories

  private static func makeLocationService() -> LiveLocationService {
    LiveLocationService(locationManager: LiveLocationManager())
  }

  private static func makeHTTPClient() -> URLSessionHTTPClient {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 5
    configuration.timeoutIntervalForResource = 5
    configuration.waitsForConnectivity = false
    return URLSessionHTTPClient(session: URLSession(configuration: configuration))
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
      remoteBookingLoader: LiveRemoteRoomBookingLoader,
      roomRatingLoader: LiveRoomRatingLoader,
      roomFilterLoader: LiveFilterRoomLoader)
  {
    let httpClient = makeHTTPClient()
    let (stagingURL, productionURL) = makeBaseURLs()

    let roomStatusLoader = LiveRoomStatusLoader(client: httpClient, baseURL: stagingURL)
    let buildingRatingLoader = RemoteBuildingRatingLoader(client: httpClient, baseURL: productionURL)
    let remoteBookingLoader = LiveRemoteRoomBookingLoader(client: httpClient, baseURL: productionURL)
    let roomRatingLoader = LiveRoomRatingLoader(client: httpClient, baseURL: productionURL)
    let roomFilterLoader = LiveFilterRoomLoader(client: httpClient, baseURL: productionURL)

    return (roomStatusLoader, buildingRatingLoader, remoteBookingLoader, roomRatingLoader, roomFilterLoader)
  }

  private static func makeBuildingInteractor(
    locationService: LiveLocationService,
    roomStatusLoader: LiveRoomStatusLoader,
    buildingRatingLoader: RemoteBuildingRatingLoader
  ) -> BuildingInteractor {
    do {
      let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: sharedContainer.mainContext)
      let buildingLoader = LiveBuildingLoader(
        swiftDataBuildingLoader: LiveSwiftDataBuildingLoader(swiftDataStore: swiftDataStore),
        JSONBuildingLoader: LiveJSONBuildingLoader(using: LiveJSONLoader<[DecodableBuilding]>()),
        roomStatusLoader: roomStatusLoader,
        buildingRatingLoader: buildingRatingLoader
      )
      return BuildingInteractor(
        buildingService: LiveBuildingService(buildingLoader: buildingLoader),
        locationService: locationService
      )
    } catch {
      fatalError("Failed to create BuildingInteractor: \(error)")
    }
  }

  private static func makeRoomInteractor(
    locationService: LiveLocationService,
    roomStatusLoader: LiveRoomStatusLoader,
    remoteBookingLoader: LiveRemoteRoomBookingLoader,
    roomRatingLoader: LiveRoomRatingLoader,
    roomFilterLoader: LiveFilterRoomLoader
  ) -> RoomInteractor {
    do {
      let swiftDataStore = try SwiftDataStore<SwiftDataRoom>(modelContext: sharedContainer.mainContext)
      let roomLoader = LiveRoomLoader(
        JSONRoomLoader: LiveJSONRoomLoader(using: LiveJSONLoader<[DecodableRoom]>()),
        roomStatusLoader: roomStatusLoader,
        swiftDataRoomLoader: LiveSwiftDataRoomLoader(swiftDataStore: swiftDataStore)
      )
      return RoomInteractor(
        roomService: LiveRoomService(
          roomLoader: roomLoader,
          roomBookingLoader: LiveRoomBookingLoader(remoteRoomBookingLoader: remoteBookingLoader),
          roomRatingLoader: roomRatingLoader, roomFilterLoader: roomFilterLoader
        ),
        locationService: locationService
      )
    } catch {
      fatalError("Failed to create RoomInteractor: \(error)")
    }
  }

  private static func makeMapViewModel(
    buildingInteractor: BuildingInteractor,
    roomInteractor: RoomInteractor,
    locationService: LiveLocationService
  ) -> LiveMapViewModel {
    let navigationInteractor = LiveNavigationInteractor(
      nagivationService: LiveNavigationService()
    )
    return LiveMapViewModel(
      buildingInteractor: buildingInteractor,
      locationInteractor: LocationInteractor(locationService: locationService),
      navigationInteractor: navigationInteractor,
      roomInteractor: roomInteractor
    )
  }
}
