//
//  FreeroomsApp.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import Apollo
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
import OSLog
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
    // UI setup
    Theme.registerFont(named: .ttCommonsPro)
    setFontOnToolbars(.ttCommonsPro)
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor(Theme.light.accent.primary)

    // Shared infrastructure
    let locationService = FreeroomsApp.makeLocationService()
    let httpClient = FreeroomsApp.makeHTTPClient()
    let (stagingURL, productionURL) = FreeroomsApp.makeBaseURLs()
    let (roomStatusLoader, buildingRatingLoader, remoteBookingLoader, roomRatingLoader, roomFilterLoader) = FreeroomsApp
      .makeRemoteLoaders()

    // Shared interactors
    let buildingInteractor = FreeroomsApp.makeBuildingInteractor(
      locationService: locationService,
      roomStatusLoader: roomStatusLoader,
      buildingRatingLoader: buildingRatingLoader)
    let roomInteractor = FreeroomsApp.makeRoomInteractor(
      locationService: locationService,
      roomStatusLoader: roomStatusLoader,
      remoteBookingLoader: remoteBookingLoader,
      roomRatingLoader: roomRatingLoader,
      roomFilterLoader: roomFilterLoader)

    _buildingViewModel = State(initialValue: LiveBuildingViewModel(interactor: buildingInteractor))
    _roomViewModel = State(initialValue: LiveRoomViewModel(interactor: roomInteractor))
    _mapViewModel = State(initialValue: FreeroomsApp.makeMapViewModel(
      buildingInteractor: buildingInteractor,
      roomInteractor: roomInteractor,
      locationService: locationService))
  }

  // MARK: Internal

  static let logger = Logger(subsystem: "com.devsoc.Freerooms", category: "FreeroomsApp")
  static var sharedContainer: ModelContainer = {
    let schema = Schema([SwiftDataRoom.self, SwiftDataFavoriteRoom.self])
    let config = ModelConfiguration(schema: schema)
    return try! ModelContainer(for: schema, configurations: [config])
  }()

  var logger: Logger { Self.logger }

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

  static func makeLiveBuildingViewModel() -> LiveBuildingViewModel {
    let locationService = makeLocationService()
    let (roomStatusLoader, buildingRatingLoader, _, _, _) = makeRemoteLoaders()

    let buildingLoader = makeBuildingLoader(
      roomStatusLoader: roomStatusLoader,
      buildingRatingLoader: buildingRatingLoader)

    let buildingService = LiveBuildingService(buildingLoader: buildingLoader)
    let interactor = BuildingInteractor(buildingService: buildingService, locationService: locationService)

    return LiveBuildingViewModel(interactor: interactor)
  }

  static func makeLiveMapViewModel() -> LiveMapViewModel {
    let locationService = makeLocationService()
    let (roomStatusLoader, buildingRatingLoader, remoteBookingLoader, roomRatingLoader, roomFilterLoader) = makeRemoteLoaders()

    let buildingLoader = makeBuildingLoader(
      roomStatusLoader: roomStatusLoader,
      buildingRatingLoader: buildingRatingLoader)

    let buildingService = LiveBuildingService(buildingLoader: buildingLoader)
    let buildingInteractor = BuildingInteractor(
      buildingService: buildingService,
      locationService: locationService)
    let locationInteractor = LocationInteractor(locationService: locationService)
    let navigationService = LiveNavigationService()
    let navigationInteractor = LiveNavigationInteractor(nagivationService: navigationService)
    let roomInteractor = makeRoomInteractor(
      locationService: locationService,
      roomStatusLoader: roomStatusLoader,
      remoteBookingLoader: remoteBookingLoader,
      roomRatingLoader: roomRatingLoader,
      roomFilterLoader: roomFilterLoader)

    return LiveMapViewModel(
      buildingInteractor: buildingInteractor,
      locationInteractor: locationInteractor,
      navigationInteractor: navigationInteractor,
      roomInteractor: roomInteractor)
  }

  static func makeLiveRoomViewModel() -> LiveRoomViewModel {
    let locationManager = LiveLocationManager()
    let locationService = LiveLocationService(locationManager: locationManager)

    let JSONRoomLoader = LiveJSONRoomLoader(using: LiveJSONLoader<[DecodableRoom]>())

    do {
      // TODO: ignore unused warning, swiftDataStore is not implemented
      let swiftDataStore = try SwiftDataStore<SwiftDataRoom>(modelContext: FreeroomsApp.sharedContainer.mainContext)
      let swiftDataRoomLoader = LiveSwiftDataRoomLoader(swiftDataStore: swiftDataStore)

      let (roomStatusLoader, _, remoteBookingLoader, roomRatingLoader, roomFilterLoader) = makeRemoteLoaders()

      let roomLoader = LiveRoomLoader(
        JSONRoomLoader: JSONRoomLoader,
        roomStatusLoader: roomStatusLoader,
        swiftDataRoomLoader: swiftDataRoomLoader)

      let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: remoteBookingLoader)

      let roomService = LiveRoomService(
        roomLoader: roomLoader,
        roomBookingLoader: roomBookingLoader,
        roomRatingLoader: roomRatingLoader,
        roomFilterLoader: roomFilterLoader)

      let favouriteService = try SwiftDataFavoriteRoomService(context: FreeroomsApp.sharedContainer.mainContext)

      let interactor = RoomInteractor(
        roomService: roomService,
        locationService: locationService,
        favouriteService: favouriteService)

      return LiveRoomViewModel(interactor: interactor)
    } catch {
      fatalError("Failed to create LiveBuildingViewModel: \(error)")
    }
  }

  // MARK: Private

  @State private var buildingViewModel: LiveBuildingViewModel
  @State private var mapViewModel: LiveMapViewModel
  @State private var roomViewModel: LiveRoomViewModel
  @State private var theme = Theme.light

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

    let roomStatusLoader = LiveRoomStatusLoader(client: httpClient, baseURL: productionURL)
    let buildingRatingLoader = RemoteBuildingRatingLoader(client: httpClient, baseURL: productionURL)
    let remoteBookingLoader = LiveRemoteRoomBookingLoader(client: httpClient, baseURL: productionURL)
    let roomRatingLoader = LiveRoomRatingLoader(client: httpClient, baseURL: productionURL)
    let roomFilterLoader = LiveFilterRoomLoader(client: httpClient, baseURL: productionURL)

    return (roomStatusLoader, buildingRatingLoader, remoteBookingLoader, roomRatingLoader, roomFilterLoader)
  }

  private static func makeBuildingInteractor(
    locationService: LiveLocationService,
    roomStatusLoader: LiveRoomStatusLoader,
    buildingRatingLoader: RemoteBuildingRatingLoader)
    -> BuildingInteractor
  {
    let buildingLoader = makeBuildingLoader(
      roomStatusLoader: roomStatusLoader,
      buildingRatingLoader: buildingRatingLoader)
    return BuildingInteractor(
      buildingService: LiveBuildingService(buildingLoader: buildingLoader),
      locationService: locationService)
  }

  private static func makeRoomInteractor(
    locationService: LiveLocationService,
    roomStatusLoader: LiveRoomStatusLoader,
    remoteBookingLoader: LiveRemoteRoomBookingLoader,
    roomRatingLoader: LiveRoomRatingLoader,
    roomFilterLoader: LiveFilterRoomLoader)
    -> RoomInteractor
  {
    do {
      let swiftDataStore = try SwiftDataStore<SwiftDataRoom>(modelContext: sharedContainer.mainContext)
      let roomLoader = LiveRoomLoader(
        JSONRoomLoader: LiveJSONRoomLoader(using: LiveJSONLoader<[DecodableRoom]>()),
        roomStatusLoader: roomStatusLoader,
        swiftDataRoomLoader: LiveSwiftDataRoomLoader(swiftDataStore: swiftDataStore))
      return RoomInteractor(
        roomService: LiveRoomService(
          roomLoader: roomLoader,
          roomBookingLoader: LiveRoomBookingLoader(remoteRoomBookingLoader: remoteBookingLoader),
          roomRatingLoader: roomRatingLoader,
          roomFilterLoader: roomFilterLoader),
        locationService: locationService)
    } catch {
      fatalError("Failed to create RoomInteractor: \(error)")
    }
  }

  private static func makeMapViewModel(
    buildingInteractor: BuildingInteractor,
    roomInteractor: RoomInteractor,
    locationService: LiveLocationService)
    -> LiveMapViewModel
  {
    let navigationInteractor = LiveNavigationInteractor(
      nagivationService: LiveNavigationService())
    return LiveMapViewModel(
      buildingInteractor: buildingInteractor,
      locationInteractor: LocationInteractor(locationService: locationService),
      navigationInteractor: navigationInteractor,
      roomInteractor: roomInteractor)
  }

  private static func makeBuildingLoader(
    roomStatusLoader: some RoomStatusLoader,
    buildingRatingLoader: some BuildingRatingLoader)
    -> some BuildingLoader
  {
    // TODO: Use .well_known url when available

    // Use the on-disk cache
    logger.trace("Attempting to access or create on-disk cache")
    let cache: any NormalizedCache
    do {
      let onDiskCacheLocation = try DevSoc.onDiskCacheLocation
      let onDiskCache = try DevSoc.createOnDiskCache(at: onDiskCacheLocation)
      cache = onDiskCache
      logger.trace("Using on-disk cache: \(onDiskCacheLocation)")
    } catch {
      logger.warning("Failed to access on-disk cache: \(error), falling back to in-memory cache")
      cache = InMemoryNormalizedCache()
    }

    let store = ApolloStore(cache: cache)
    let client = DevSoc.createLiveApolloClient(using: store)

    let buildingsCache: (any BuildingsCache)?
    do {
      buildingsCache = try OnDiskBuildingsCache.shared.get()
    } catch {
      logger.warning("Failed to access buildings cache: \(error), disabling caching for buildings")
      buildingsCache = nil
    }

    return LiveGraphQLBuildingLoader(
      client: client,
      roomStatusLoader: roomStatusLoader,
      buildingRatingLoader: buildingRatingLoader,
      buildingsCache: buildingsCache)
  }
}
