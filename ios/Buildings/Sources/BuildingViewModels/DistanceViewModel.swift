//
//  DistanceViewModel.swift
//  Buildings
//
//  Created by Eric Wong on 21/11/2026.
//

public import BuildingInteractors
public import BuildingModels
import BuildingServices
public import Location
public import Observation
public import RoomInteractors
public import RoomModels
import RoomServices

// MARK: - LiveDistanceViewModel

/// The one owner of location permission, where the user is, and how far they are from each
/// building and room. It reads the location once per reload and works distances out from the
/// buildings and rooms the app already holds, so it never fetches anything itself.
@Observable
@MainActor
public class LiveDistanceViewModel {

  // MARK: Lifecycle

  public init(buildingInteractor: BuildingInteractor, roomInteractor: RoomInteractor) {
    self.buildingInteractor = buildingInteractor
    self.roomInteractor = roomInteractor
  }

  // MARK: Public

  /// Where the user is, for sorting by distance. `nil` without location permission or a GPS fix.
  public private(set) var userLocation: Location?
  public private(set) var distanceFromUserByBuildingID: [String: Double] = [:]
  public private(set) var distanceFromUserByRoomID: [String: Double] = [:]

  /// Whether there's a location to sort by.
  public var canSortByDistance: Bool {
    userLocation != nil
  }

  /// Shows the system prompt if the user hasn't been asked yet.
  public func requestLocationPermission() {
    _ = try? buildingInteractor.requestLocationPermission()
  }

  /// Re-reads the user's location. Recomputes distances only when the location appeared,
  /// disappeared or moved at least 25 m, so GPS jitter doesn't redraw every tile.
  public func reload() async {
    let newLocation = buildingInteractor.getUserLocation()
    guard Location.hasChanged(from: userLocation, to: newLocation, byAtLeast: Self.minimumMovementInMetres) else {
      return
    }
    userLocation = newLocation
    updateDistances()
  }

  /// Keeps the location current while the app is open, until the calling task is cancelled.
  /// Checks every few seconds until the first GPS fix, then every 30 seconds.
  ///
  /// A stopgap: the location service can only notify one listener and the Map tab uses it.
  /// Once it can notify several, react to its updates instead of polling.
  public func keepLocationCurrent() async {
    while !Task.isCancelled {
      await reload()
      let interval = userLocation == nil ? Self.checkIntervalWithoutLocation : Self.checkInterval
      try? await Task.sleep(for: interval)
    }
  }

  /// Recomputes distances for a new list of buildings.
  public func update(buildings: [Building]) {
    self.buildings = buildings
    updateDistances()
  }

  /// Recomputes distances for a new list of rooms. Does nothing when only their order changed
  /// (for example after Reverse), as no room has moved.
  public func update(rooms: [Room]) {
    guard Set(rooms.map(\.id)) != Set(self.rooms.map(\.id)) else { return }
    self.rooms = rooms
    updateDistances()
  }

  // MARK: Private

  private static let checkInterval: Swift.Duration = .seconds(30)
  private static let checkIntervalWithoutLocation: Swift.Duration = .seconds(5)
  private static let minimumMovementInMetres = 25.0

  private let buildingInteractor: BuildingInteractor
  private let roomInteractor: RoomInteractor
  private var buildings: [Building] = []
  private var rooms: [Room] = []

  /// Rooms use their building's distance when they have no coordinates of their own.
  private func updateDistances() {
    guard let userLocation else {
      distanceFromUserByBuildingID = [:]
      distanceFromUserByRoomID = [:]
      return
    }
    let buildingDistances = buildingInteractor.getDistances(to: buildings, from: userLocation)
    distanceFromUserByBuildingID = buildingDistances
    distanceFromUserByRoomID = roomInteractor.getRoomDistances(
      rooms,
      from: userLocation,
      buildingDistances: buildingDistances)
  }

}

// MARK: - PreviewDistanceViewModel

@Observable
public class PreviewDistanceViewModel: LiveDistanceViewModel {

  public init() {
    super.init(
      buildingInteractor: BuildingInteractor(
        buildingService: PreviewBuildingService(),
        locationService: LiveLocationService(locationManager: LiveLocationManager())),
      roomInteractor: RoomInteractor(
        roomService: PreviewRoomService(),
        favouriteService: PreviewFavoriteRoomService()))
  }
}
