//
//  NearestBuildingsTests.swift
//  Buildings
//
//  Created by Eric Wong on 11/11/2026.
//

import BuildingModels
import CoreLocation
import Foundation
import Testing
@testable import BuildingInteractors
@testable import BuildingServices
@testable import Location

// MARK: - NearestBuildingsTests

struct NearestBuildingsTests {

  // MARK: Internal

  @Test("Gives each building's distance from the origin in metres")
  func givesDistancesInMetres() {
    // Given: 0.001° of latitude is about 111 m.
    let hundred = building("One hundred", latitudeOffset: 0.001)
    let twoHundred = building("Two hundred", latitudeOffset: 0.002)
    let sut = makeNearestSUT(buildings: [], userLocation: userLocation)

    // When
    let distances = sut.getDistances(to: [twoHundred, hundred], from: userLocation)

    // Then
    #expect(distances.count == 2)
    #expect(abs((distances[hundred.id] ?? .nan) - 111) < 2)
    #expect(abs((distances[twoHundred.id] ?? .nan) - 222) < 3)
  }

  @Test("Measures real distance, not raw degrees")
  func measuresRealDistanceNotRawDegrees() {
    // Given: at UNSW a degree of longitude is ~17% shorter than a degree of latitude, so
    // 0.0012° east (~111 m) is closer than 0.0011° north (~122 m), even though 0.0012 > 0.0011.
    let north = building("North", latitudeOffset: 0.0011)
    let east = building("East", longitudeOffset: 0.0012)
    let sut = makeNearestSUT(buildings: [], userLocation: userLocation)

    // When
    let distances = sut.getDistances(to: [north, east], from: userLocation)

    // Then
    guard let northDistance = distances[north.id], let eastDistance = distances[east.id] else {
      Issue.record("Expected a distance for both buildings")
      return
    }
    #expect(eastDistance < northDistance)
  }

  @Test("Keeps the first entry when a building ID appears twice")
  func keepsFirstEntryForDuplicateBuilding() {
    // Given: two buildings share an ID but sit at different distances.
    let first = building("Twice", latitudeOffset: 0.001)
    let second = Building(
      name: "Twice again",
      id: first.id,
      latitude: userLocation.latitude + 0.002,
      longitude: userLocation.longitude,
      aliases: [],
      numberOfAvailableRooms: nil)
    let sut = makeNearestSUT(buildings: [], userLocation: userLocation)

    // When
    let distances = sut.getDistances(to: [first, second], from: userLocation)

    // Then
    #expect(distances.count == 1)
    #expect(abs((distances[first.id] ?? .nan) - 111) < 2)
  }

  @Test("Gives the user's location when there's permission and a fix")
  func givesUserLocation() {
    // Given
    let sut = makeNearestSUT(buildings: [], userLocation: userLocation)

    // When
    let location = sut.getUserLocation()

    // Then
    #expect(location == userLocation)
  }

  @Test("Gives no user location without permission")
  func givesNoUserLocationWithoutPermission() {
    // Given
    let sut = makeNearestSUT(buildings: [], userLocation: userLocation, authorizationStatus: .denied)

    // When
    let location = sut.getUserLocation()

    // Then
    #expect(location == nil)
  }

  // Nearest to a building (getBuildingsNearest)

  @Test("Nearest to a building leaves out the building itself")
  func nearestToBuildingExcludesItself() async {
    // Given: the building we measure from is also in the service's list, as it is in the app.
    let origin = building("Origin", latitudeOffset: 0.001)
    let buildings = [
      origin,
      building("Neighbour", latitudeOffset: 0.0012),
      building("Further", latitudeOffset: 0.002),
    ]
    let sut = makeNearestSUT(buildings: buildings, userLocation: userLocation)

    // When
    let result = await sut.getBuildingsNearest(from: origin, limit: 3)

    // Then
    guard case .success(let nearest) = result else {
      Issue.record("Expected success but got failure")
      return
    }
    #expect(nearest.map(\.building.name) == ["Neighbour", "Further"])
  }

  @Test("Nearest to a building measures from that building, not from the user")
  func nearestToBuildingMeasuresFromBuilding() async {
    // Given: the origin is ~1.1 km north of the user, so "Near user" is far from it.
    let origin = building("Origin", latitudeOffset: 0.01)
    let buildings = [
      building("Near user", latitudeOffset: 0.0001),
      building("Next to origin", latitudeOffset: 0.0102),
      building("Close to origin", latitudeOffset: 0.0108),
    ]
    let sut = makeNearestSUT(buildings: buildings, userLocation: userLocation)

    // When
    let result = await sut.getBuildingsNearest(from: origin, limit: 3)

    // Then
    guard case .success(let nearest) = result else {
      Issue.record("Expected success but got failure")
      return
    }
    #expect(nearest.map(\.building.name) == ["Next to origin", "Close to origin", "Near user"])
    #expect((17...27).contains(nearest[0].distanceInMetres)) // 0.0002° north ≈ 22 m
  }

  @Test("Nearest to a building works without location permission")
  func nearestToBuildingWorksWithoutLocation() async {
    // Given: permission denied and no GPS fix, which would make sorting by the user's distance fail.
    let origin = building("Origin")
    let sut = makeNearestSUT(
      buildings: [building("Neighbour", latitudeOffset: 0.0005)],
      userLocation: nil,
      authorizationStatus: .denied)

    // When
    let result = await sut.getBuildingsNearest(from: origin, limit: 3)

    // Then
    guard case .success(let nearest) = result else {
      Issue.record("Expected success but got failure")
      return
    }
    #expect(nearest.map(\.building.name) == ["Neighbour"])
  }

  @Test("Nearest to a building skips full buildings and respects the limit")
  func nearestToBuildingSkipsFullAndRespectsLimit() async {
    // Given
    let origin = building("Origin")
    let buildings = [
      building("Full", latitudeOffset: 0.0002, availableRooms: 0),
      building("First", latitudeOffset: 0.0004, availableRooms: 2),
      building("Second", latitudeOffset: 0.0006),
      building("Third", latitudeOffset: 0.0008, availableRooms: 5),
    ]
    let sut = makeNearestSUT(buildings: buildings, userLocation: userLocation)

    // When
    let result = await sut.getBuildingsNearest(from: origin, limit: 2)

    // Then
    guard case .success(let nearest) = result else {
      Issue.record("Expected success but got failure")
      return
    }
    #expect(nearest.map(\.building.name) == ["First", "Second"])
  }

  @Test("Nearest to a building fails when buildings can't be loaded")
  func nearestToBuildingFailsWhenBuildingsFailToLoad() async {
    // Given
    let stubLoader = StubBuildingLoader()
    stubLoader.fetchReturnValue = .failure(.connectivity)
    let sut = makeNearestSUT(loader: stubLoader, userLocation: userLocation)

    // When
    let result = await sut.getBuildingsNearest(from: building("Origin"), limit: 3)

    // Then
    guard case .failure = result else {
      Issue.record("Expected failure but got success")
      return
    }
  }

  // MARK: Private

  /// Roughly the middle of UNSW Kensington.
  private let userLocation = Location(latitude: -33.9173, longitude: 151.2312)

  /// A building offset from `userLocation` by the given number of degrees.
  private func building(
    _ name: String,
    latitudeOffset: Double = 0,
    longitudeOffset: Double = 0,
    availableRooms: Int? = nil)
    -> Building
  {
    Building(
      name: name,
      id: "K-\(name)",
      latitude: userLocation.latitude + latitudeOffset,
      longitude: userLocation.longitude + longitudeOffset,
      aliases: [],
      numberOfAvailableRooms: availableRooms)
  }

  private func makeNearestSUT(
    buildings: [Building],
    userLocation: Location?,
    authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse)
    -> BuildingInteractor
  {
    let stubLoader = StubBuildingLoader()
    stubLoader.fetchReturnValue = .success(buildings)
    return makeNearestSUT(loader: stubLoader, userLocation: userLocation, authorizationStatus: authorizationStatus)
  }

  private func makeNearestSUT(
    loader: StubBuildingLoader,
    userLocation: Location?,
    authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse)
    -> BuildingInteractor
  {
    let spyLocationManager = SpyLocationManager()
    // Set before creating the service: LiveLocationService reads the permission in its init.
    spyLocationManager.authorizationStatus = authorizationStatus
    spyLocationManager.location = userLocation
    let locationService = LiveLocationService(locationManager: spyLocationManager)
    let buildingService = LiveBuildingService(buildingLoader: loader)
    return BuildingInteractor(buildingService: buildingService, locationService: locationService)
  }
}
