//
//  MapViewModel.swift
//  Map
//
//  Created by Dicko Evaldo
//

import BottomSheet
import BuildingInteractors
import BuildingModels
import BuildingServices
import Combine
import Foundation
import Location
import LocationInteractors
import LocationTestsUtils
@preconcurrency import MapKit
import SwiftUI

// MARK: - MapViewModel

@MainActor
public protocol MapViewModel {
  var buildings: [Building] { get }
  var position: MapCameraPosition { get set }
  var isLoading: Bool { get }
  var selectedBuildingID: String? { get }
  var selectedBuildingName: String { get }
  var selectedBuildingAvailableRooms: Int { get }
  var mapCameraBounds: MapCameraBounds { get }
  var selectedBuildingAvailabilityColour: Color { get }

  /// Sheet fields
  var bottomSheetPosition: BottomSheetPosition { get set }

  // Look Around Fields
  var lookAroundScene: MKLookAroundScene? { get }
  var isLoadingLookAround: Bool { get }

  // Routing Fields
  var currentRoute: MKRoute? { get }
  var currentRouteETA: TimeInterval { get }
  var userHeading: CLHeading { get }
  var mapHeading: Double { get set }
  var isLoadingCurrentRoute: Bool { get }
  var currentRouteErrorMessage: String? { get }
  func getDirectionToSelectedBuilding() async
  func onGetDirection() async
  func clearDirection()

  // Search Bar
  var searchText: String { get set }
  var filteredBuildings: [Building] { get set }
  func performSearch()
  func executeSearch() async
  func clearSearch()
  nonisolated func filterBuildings(_ buildings: [Building], query: String) async -> [Building]

  func loadBuildings() async
  func selectBuilding(_ buildingID: String)
  func isSelectedBuilding(_ buildingID: String) -> Bool
  func unselectBuilding()
  func loadLookAroundScene(coordinate: CLLocationCoordinate2D) async
  func requestLocationPermission()
  func getUserLocation() -> Location?
  func setupLocationUpdates()
  func setupHeadingUpdates()
  func updateMapHeading(_ heading: Double)
  func handleLocationUpdate(_ newLocation: Location) async
  func handleHeadingUpdate(_ newHeading: CLHeading)
  func focusBuildingOnMap()
  func onSelectBuilding(_ buildingID: String)
  func onClearBuildingSelection()
}

// MARK: - SheetPosition

public enum SheetPosition {
  case hidden
  case short
  case medium

  // MARK: Public

  public var bottomSheetPosition: BottomSheetPosition {
    switch self {
    case .hidden:
      .hidden
    case .short:
      .relative(0.2)
    case .medium:
      .relative(0.55)
    }
  }
}

extension CLLocationCoordinate2D {
  static let campusCenter = CLLocationCoordinate2D(latitude: -33.9173, longitude: 151.2312)
}

extension MKMultiPoint {
  public var coordinates: [CLLocationCoordinate2D] {
    var coords = [CLLocationCoordinate2D](
      repeating: kCLLocationCoordinate2DInvalid,
      count: pointCount)

    getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

    return coords
  }
}

extension MKCoordinateRegion {
  static let campusRegion = MKCoordinateRegion(
    center: .campusCenter,
    span: MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009))
}

extension Building {
  public var availabilityColor: Color {
    guard let numberOfAvailableRooms else { return .gray }
    switch numberOfAvailableRooms {
    case 0: return .red
    case 1...3: return .orange
    default: return .green
    }
  }
}

extension TimeInterval {
  /// More detailed walking time with hours and minutes
  public var detailedWalkingTime: String {
    let totalMinutes = Int(self / 60)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60

    if hours > 0 {
      if minutes > 0 {
        return "\(hours)Hour \(minutes)Min"
      } else {
        return "\(hours)Hour"
      }
    } else if minutes < 1 {
      return "< 1 Min"
    } else {
      return "\(minutes) Min\(minutes == 1 ? "" : "s")"
    }
  }
}

// MARK: - LiveMapViewModel

@MainActor
@Observable
public class LiveMapViewModel: MapViewModel {

  // MARK: Lifecycle

  public init(
    buildingInteractor: BuildingInteractor,
    locationInteractor: LocationInteractor,
    navigationInteractor: NavigationInteractor)
  {
    self.buildingInteractor = buildingInteractor
    self.locationInteractor = locationInteractor
    self.navigationInteractor = navigationInteractor

    setupLocationUpdates()
    setupHeadingUpdates()
  }

  // MARK: Public

  public var currentRouteErrorMessage: String?

  public var isLoadingCurrentRoute = false

  public var mapHeading: Double = 0

  public var bottomSheetPosition = SheetPosition.hidden.bottomSheetPosition

  public var userHeading = CLHeading()

  public var currentRoute: MKRoute?

  public var lookAroundScene: MKLookAroundScene?
  public var isLoadingLookAround = false

  public var buildings: [Building] = []
  public var position = MapCameraPosition.region(.campusRegion)
  public var isLoading = false
  public var mapCameraBounds = MapCameraBounds(centerCoordinateBounds: .campusRegion, minimumDistance: 500, maximumDistance: 5000)

  public var selectedBuildingID: String?

  public var filteredBuildings: [Building] = []

  public var searchText = "" {
    didSet {
      performSearch()
    }
  }

  public var selectedBuildingAvailableRooms: Int {
    selectedBuilding?.numberOfAvailableRooms ?? 0
  }

  public var selectedBuildingAvailabilityColour: Color {
    selectedBuilding?.availabilityColor ?? .gray
  }

  public var currentRouteETA: TimeInterval {
    currentRoute?.expectedTravelTime ?? 0
  }

  public var selectedBuildingName: String {
    selectedBuilding?.name ?? ""
  }

  public var selectedBuildingCoordinate: CLLocationCoordinate2D? {
    selectedBuilding?.coordinate
  }

  public func updateMapHeading(_ heading: Double) {
    mapHeading = heading
  }

  public func performSearch() {
    searchDebounceTask?.cancel()

    searchDebounceTask = Task {
      try? await Task.sleep(for: .milliseconds(200))

      guard !Task.isCancelled else { return }

      await executeSearch()
    }
  }

  public func executeSearch() async {
    searchTask?.cancel()

    let searchQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !searchQuery.isEmpty else {
      filteredBuildings = buildings
      return
    }

    searchTask = Task {
      let buildingsToFilter = buildings
      let query = searchQuery.lowercased()

      let filtered = await filterBuildings(buildingsToFilter, query: query)

      guard !Task.isCancelled else { return }

      // Update results (back on MainActor automatically)
      self.filteredBuildings = filtered
    }
  }

  nonisolated public func filterBuildings(_ buildings: [Building], query: String) async -> [Building] {
    buildings.filter { building in
      building.name.lowercased().contains(query)
    }
  }

  public func onClearBuildingSelection() {
    unselectBuilding()
    bottomSheetPosition = SheetPosition.hidden.bottomSheetPosition
  }

  public func onGetDirection() async {
    bottomSheetPosition = SheetPosition.short.bottomSheetPosition
    await getDirectionToSelectedBuilding()
  }

  public func onSelectBuilding(_ buildingID: String) {
    clearDirection()
    selectBuilding(buildingID)
    bottomSheetPosition = SheetPosition.medium.bottomSheetPosition
  }

  public func handleHeadingUpdate(_ newHeading: CLHeading) {
    userHeading = newHeading
  }

  public func setupHeadingUpdates() {
    locationInteractor.setHeadingUpdateCallback { [weak self] newHeading in
      self?.handleHeadingUpdate(newHeading)
    }
  }

  public func focusBuildingOnMap() {
    guard let building = selectedBuilding else { return }

    position = .camera(
      MapCamera(
        centerCoordinate: building.coordinate,
        distance: 1000,
        heading: 0,
        pitch: 0))
  }

  public func clearSearch() {
    searchText = ""
  }

  public func setupLocationUpdates() {
    locationInteractor.setLocationUpdateCallback { [weak self] newLocation in
      Task {
        await self?.handleLocationUpdate(newLocation)
      }
    }
  }

  public func handleLocationUpdate(_ newLocation: Location) async {
    guard currentRoute != nil, selectedBuildingCoordinate != nil else { return }

    guard lastDirectionUpdateLocation != nil else {
      lastDirectionUpdateLocation = newLocation.coordinate
      return
    }

    var exceedDistanceMove = true
    let lastLocation = CLLocation(
      latitude: lastDirectionUpdateLocation!.latitude,
      longitude: lastDirectionUpdateLocation!.longitude)
    let newLocation = newLocation.clLocation

    let distance = lastLocation.distance(from: newLocation)
    exceedDistanceMove = distance >= minimumDistanceForUpdate

    guard exceedDistanceMove else {
      return
    }

    lastDirectionUpdateLocation = newLocation.coordinate
    await getDirectionToSelectedBuilding()
  }

  public func getDirectionToSelectedBuilding() async {
    currentRouteErrorMessage = nil
    isLoadingCurrentRoute = true

    defer {
      isLoadingCurrentRoute = false
    }

    guard let selectedBuilding else {
      return
    }

    guard let userCoordinate = getUserLocation() else {
      return
    }

    do {
      let route = try await navigationInteractor.getRouteToBuilding(building: selectedBuilding, location: userCoordinate)
      currentRoute = route
    } catch {
      currentRouteErrorMessage = error.localizedDescription
    }
  }

  public func clearDirection() {
    currentRoute = nil
    bottomSheetPosition = SheetPosition.medium.bottomSheetPosition
  }

  public func getUserLocation() -> Location? {
    do {
      return try locationInteractor.getUserLocation()
    } catch {
      currentRouteErrorMessage = "Failed to get user location"
    }

    return nil
  }

  public func requestLocationPermission() {
    do {
      let _ = try locationInteractor.requestLocationPermission()
    } catch {
      return
    }
  }

  public func loadLookAroundScene(coordinate: CLLocationCoordinate2D) async {
    isLoadingLookAround = true
    lookAroundScene = nil

    let request = MKLookAroundSceneRequest(coordinate: coordinate)
    do {
      lookAroundScene = try await request.scene
    } catch {
      lookAroundScene = nil
    }

    isLoadingLookAround = false
  }

  public func loadBuildings() async {
    isLoading = true

    defer {
      isLoading = false
    }

    switch await buildingInteractor.getBuildingsSortedAlphabetically(inAscendingOrder: true) {
    case .success(let buildings):
      self.buildings = buildings
    case .failure:
      return
    }
  }

  public func selectBuilding(_ buildingID: String) {
    selectedBuildingID = buildingID

    if let building = buildings.first(where: { $0.id == buildingID }) {
      Task {
        await loadLookAroundScene(coordinate: building.coordinate)
      }
    }
  }

  public func isSelectedBuilding(_ buildingID: String) -> Bool {
    buildingID == selectedBuildingID
  }

  public func unselectBuilding() {
    selectedBuildingID = nil
  }

  // MARK: Internal

  nonisolated let buildingInteractor: BuildingInteractor

  nonisolated let navigationInteractor: NavigationInteractor

  var selectedBuilding: Building? {
    guard let selectedBuildingID else { return nil }

    return buildings.first { $0.id == selectedBuildingID }
  }

  // MARK: Private

  private let locationInteractor: LocationInteractor
  private var searchTask: Task<Void, Never>?
  private var searchDebounceTask: Task<Void, Never>?
  private var lastDirectionUpdateLocation: CLLocationCoordinate2D?
  private let minimumDistanceForUpdate: CLLocationDistance = 20.0

}

// MARK: - PreviewMapViewModel

@MainActor
@Observable
// swiftlint:disable:next no_unchecked_sendable
public class PreviewMapViewModel: LiveMapViewModel, @unchecked Sendable {

  // MARK: Lifecycle

  public init() {
    super.init(
      buildingInteractor: BuildingInteractor(
        buildingService: PreviewBuildingService(),
        locationService: PreviewLocationService()),
      locationInteractor: LocationInteractor(locationService: PreviewLocationService()),
      navigationInteractor: PreviewNavigationInteractor())

    buildings = [
      Building(
        name: "AGSM",
        id: "K-G27",
        latitude: -33.91852,
        longitude: 151.235664,
        aliases: [],
        numberOfAvailableRooms: 5),
      Building(
        name: "Ainsworth Building",
        id: "K-J17",
        latitude: -33.918527,
        longitude: 151.23126,
        aliases: [],
        numberOfAvailableRooms: 2),
      Building(
        name: "Biological Sciences",
        id: "K-E26",
        latitude: -33.917682,
        longitude: 151.235736,
        aliases: [],
        numberOfAvailableRooms: 0),
      Building(
        name: "Anita B Lawrence Centre",
        id: "K-H13",
        latitude: -33.917876,
        longitude: 151.230057,
        aliases: ["Red Centre"],
        numberOfAvailableRooms: 8),
      Building(
        name: "Main Library",
        id: "K-F21",
        latitude: -33.917528,
        longitude: 151.233439,
        aliases: [],
        numberOfAvailableRooms: 12),
    ]
  }

  // MARK: Public

  public override func loadBuildings() async {
    isLoading = true

    // Simulate delay from fetching buildings
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }

      isLoading = false
    }
  }
}
