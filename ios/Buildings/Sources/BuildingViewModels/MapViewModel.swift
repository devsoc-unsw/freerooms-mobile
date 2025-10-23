//  MapViewModel.swift
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
  var lookAroundScene: MKLookAroundScene? { get }
  var isLoadingLookAround: Bool { get }
  var currentRoute: MKRoute? { get }
  var currentRouteETA: TimeInterval { get }
  var searchText: String { get set }

  func loadBuildings() async
  func selectBuilding(_ buildingID: String) async
  func isSelectedBuilding(_ buildingID: String) -> Bool
  func unselectBuilding()
  func loadLookAroundScene(coordinate: CLLocationCoordinate2D) async
  func requestLocationPermission() throws -> Bool
  func getUserLocation() -> Location?
  func getDirectionToSelectedBuilding() async
  func clearDirection()
  func setupLocationUpdates()
  func handleLocationUpdate(_ newLocation: Location) async
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
  public var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }

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
        return "\(hours)h \(minutes)m walk"
      } else {
        return "\(hours)h walk"
      }
    } else if minutes < 1 {
      return "< 1 min walk"
    } else {
      return "\(minutes) min\(minutes == 1 ? "" : "s") walk"
    }
  }
}

// MARK: - LiveMapViewModel

@MainActor
@Observable
public class LiveMapViewModel: MapViewModel {

  // MARK: Lifecycle

  public init(buildingInteractor: BuildingInteractor, locationInteractor: LocationInteractor) {
    self.buildingInteractor = buildingInteractor
    self.locationInteractor = locationInteractor

    setupLocationUpdates()
  }

  // MARK: Public

  public var searchText = ""

  public var currentRoute: MKRoute?

  public var lookAroundScene: MKLookAroundScene?
  public var isLoadingLookAround = false

  public var buildings: [Building] = []
  public var position = MapCameraPosition.region(.campusRegion)
  public var isLoading = false
  public var selectedBuildingID: String?
  public var mapCameraBounds = MapCameraBounds(centerCoordinateBounds: .campusRegion, minimumDistance: 500, maximumDistance: 5000)

  public var selectedBuildingAvailableRooms: Int {
    selectedBuilding?.numberOfAvailableRooms ?? 0
  }

  public var currentRouteETA: TimeInterval {
    currentRoute?.expectedTravelTime ?? 0
  }

  public var selectedBuildingName: String {
    selectedBuilding?.name ?? "No building selected"
  }

  public var selectedBuildingCoordinate: CLLocationCoordinate2D? {
    selectedBuilding?.coordinate
  }

  public func setupLocationUpdates() {
    locationInteractor.setLocationUpdateCallback { [weak self] newLocation in
      Task {
        await self?.handleLocationUpdate(newLocation)
      }
    }
  }

  public func handleLocationUpdate(_: Location) async {
    guard currentRoute != nil, selectedBuildingCoordinate != nil else { return }
    await getDirectionToSelectedBuilding()
  }

  public func getDirectionToSelectedBuilding() async {
    // swiftlint:disable:next no_direct_standard_out_logs
    print("getting directionminn")

    guard let selectedCoordinate = selectedBuildingCoordinate else {
      return
    }

    guard let userCoordinate = getUserLocation() else {
      return
    }

    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2DMake(
      userCoordinate.latitude,
      userCoordinate.longitude)))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: selectedCoordinate))
    request.transportType = .walking

    let directions = MKDirections(request: request)

    do {
      let response = try await directions.calculate()
      currentRoute = response.routes.first
    } catch {
      // swiftlint:disable:next no_direct_standard_out_logs
      print("error calculating distance \(error)")
    }
  }

  public func clearDirection() {
    currentRoute = nil
  }

  public func getUserLocation() -> Location? {
    do {
      return try locationInteractor.getUserLocation()
    } catch {
      // swiftlint:disable:next no_direct_standard_out_logs
      print("failed to get user location \(error)")
    }

    return nil
  }

  public func requestLocationPermission() throws -> Bool {
    try locationInteractor.requestLocationPermission()
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

    do {
      // TODO UNUSED VAR
      let _ = try requestLocationPermission()
    } catch {
      // TODO fix error handling
      // swiftlint:disable:next no_direct_standard_out_logs
      print("error: \(error)")
    }

    switch await buildingInteractor.getBuildingsSortedAlphabetically(inAscendingOrder: true) {
    case .success(let buildings):
      self.buildings = buildings
      isLoading = false

    case .failure:
      isLoading = false
    }
  }

  public func selectBuilding(_ buildingID: String) async {
    selectedBuildingID = buildingID

    if let building = buildings.first(where: { $0.id == buildingID }) {
      await loadLookAroundScene(coordinate: building.coordinate)
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

  let locationInteractor: LocationInteractor

  var selectedBuilding: Building? {
    guard let selectedBuildingID else { return nil }
    return buildings.first { $0.id == selectedBuildingID }
  }

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
        locationService: PreviewLocationService(locationManager: MockLocationManager())),
      locationInteractor: LocationInteractor(locationService: PreviewLocationService(locationManager: MockLocationManager())))

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
