//
//  FreeroomsApp.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import Apollo
import BookingInteractors
import BookingServices
import BookingViewModels
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
    UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor(Theme.default.accent.primary)

    // Shared infrastructure
    let locationService = FreeroomsApp.makeLocationService()
    let apolloClient = FreeroomsApp.makeApolloClient()
    let (roomStatusLoader, buildingRatingLoader, remoteBookingLoader, roomRatingLoader, roomFilterLoader) = FreeroomsApp
      .makeRemoteLoaders()

    // Shared interactors
    let buildingInteractor = FreeroomsApp.makeBuildingInteractor(
      locationService: locationService,
      apolloClient: apolloClient,
      roomStatusLoader: roomStatusLoader,
      buildingRatingLoader: buildingRatingLoader)
    let roomInteractor = FreeroomsApp.makeRoomInteractor(
      locationService: locationService,
      roomStatusLoader: roomStatusLoader,
      remoteBookingLoader: remoteBookingLoader,
      roomRatingLoader: roomRatingLoader,
      roomFilterLoader: roomFilterLoader)
    let bookingInteractor = FreeroomsApp.makeBookingInteractor(apolloClient: apolloClient)

    _buildingViewModel = State(initialValue: LiveBuildingViewModel(interactor: buildingInteractor))
    _roomViewModel = State(initialValue: LiveRoomViewModel(interactor: roomInteractor))
    _bookingViewModel = State(initialValue: LiveBookingViewModel(interactor: bookingInteractor))
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
        .environment(Theme.default)
        .environment(\.font, Font.custom(.ttCommonsPro, size: 14))
        .environment(\.buildingViewModel, buildingViewModel)
        .environment(\.mapViewModel, mapViewModel)
        .environment(\.roomViewModel, roomViewModel)
        .environment(buildingViewModel)
        .environment(mapViewModel)
        .environment(roomViewModel)
        .environment(bookingViewModel)
    }
  }

  // MARK: Private

  /// Keep room/building metadata requests responsive so loading states fail quickly instead of hanging.
  private static let httpRequestTimeout: TimeInterval = 5
  private static let httpResourceTimeout: TimeInterval = 5

  @State private var buildingViewModel: LiveBuildingViewModel
  @State private var bookingViewModel: LiveBookingViewModel
  @State private var mapViewModel: LiveMapViewModel
  @State private var roomViewModel: LiveRoomViewModel

  // MARK: - Factories

  private static func makeLocationService() -> LiveLocationService {
    LiveLocationService(locationManager: LiveLocationManager())
  }

  private static func makeHTTPClient() -> URLSessionHTTPClient {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = Self.httpRequestTimeout
    configuration.timeoutIntervalForResource = Self.httpResourceTimeout
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
      roomFilterService: LiveFilterRoomService)
  {
    let httpClient = makeHTTPClient()
    let (_, productionURL) = makeBaseURLs()

    let roomStatusLoader = LiveRoomStatusLoader(client: httpClient, baseURL: productionURL)
    let buildingRatingLoader = RemoteBuildingRatingLoader(client: httpClient, baseURL: productionURL)
    let remoteBookingLoader = LiveRemoteRoomBookingLoader(client: httpClient, baseURL: productionURL)
    let roomRatingLoader = LiveRoomRatingLoader(client: httpClient, baseURL: productionURL)
    let roomFilterService = LiveFilterRoomService(client: httpClient, baseURL: productionURL)

    return (roomStatusLoader, buildingRatingLoader, remoteBookingLoader, roomRatingLoader, roomFilterService)
  }

  private static func makeBuildingInteractor(
    locationService: LiveLocationService,
    apolloClient: ApolloClient,
    roomStatusLoader: LiveRoomStatusLoader,
    buildingRatingLoader: RemoteBuildingRatingLoader)
    -> BuildingInteractor
  {
    let buildingLoader = makeBuildingLoader(
      apolloClient: apolloClient,
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
    roomFilterLoader: LiveFilterRoomService)
    -> RoomInteractor
  {
    do {
      let swiftDataStore = try SwiftDataStore<SwiftDataRoom>(modelContext: sharedContainer.mainContext)
      let favouriteService = try SwiftDataFavoriteRoomService(context: sharedContainer.mainContext)
      let roomLoader = LiveRoomLoader(
        JSONRoomLoader: LiveJSONRoomLoader(using: LiveJSONLoader<[DecodableRoom]>()),
        roomStatusLoader: roomStatusLoader,
        swiftDataRoomLoader: LiveSwiftDataRoomLoader(swiftDataStore: swiftDataStore))
      return RoomInteractor(
        roomService: LiveRoomService(
          roomLoader: roomLoader,
          roomBookingLoader: LiveRoomBookingLoader(remoteRoomBookingLoader: remoteBookingLoader),
          roomRatingLoader: roomRatingLoader,
          roomFilterService: roomFilterLoader),
        locationService: locationService,
        favouriteService: favouriteService)
    } catch {
      fatalError("Failed to create RoomInteractor: \(error)")
    }
  }

  private static func makeBookingInteractor(apolloClient: ApolloClient) -> BookingInteractor {
    BookingInteractor(
      service: LiveBookingService(
        loader: LiveGraphQLWeeklyBookingLoader(client: apolloClient)))
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
    apolloClient: ApolloClient,
    roomStatusLoader: some RoomStatusLoader,
    buildingRatingLoader: some BuildingRatingLoader)
    -> some BuildingLoader
  {
    let buildingsCache: (any BuildingsCache)?
    do {
      buildingsCache = try OnDiskBuildingsCache.shared.get()
    } catch {
      logger.warning("Failed to access buildings cache: \(error), disabling caching for buildings")
      buildingsCache = nil
    }

    return LiveGraphQLBuildingLoader(
      client: apolloClient,
      roomStatusLoader: roomStatusLoader,
      buildingRatingLoader: buildingRatingLoader,
      buildingsCache: buildingsCache)
  }

  private static func makeApolloClient() -> ApolloClient {
    logger.trace("Attempting to access or create on-disk Apollo cache")
    let cache: any NormalizedCache
    do {
      let onDiskCacheLocation = try DevSoc.onDiskCacheLocation
      cache = try DevSoc.createOnDiskCache(at: onDiskCacheLocation)
      logger.trace("Using on-disk Apollo cache: \(onDiskCacheLocation)")
    } catch {
      logger.warning("Failed to access on-disk Apollo cache: \(error), falling back to in-memory cache")
      cache = InMemoryNormalizedCache()
    }

    return DevSoc.createLiveApolloClient(using: ApolloStore(cache: cache))
  }
}
