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

  @Test("Returns buildings ordered from closest to furthest")
  func returnsClosestBuildingFirst() async {
    // Given
    let buildings = [
      building("Far", latitudeOffset: 0.003),
      building("Closest", latitudeOffset: 0.0005),
      building("Middle", latitudeOffset: 0.0015),
    ]
    let sut = makeNearestSUT(buildings: buildings, userLocation: userLocation)

    // When
    let result = await sut.getNearestBuildings(limit: 3)

    // Then
    guard case .success(let nearest) = result else {
      Issue.record("Expected success but got failure")
      return
    }
    #expect(nearest.map(\.building.name) == ["Closest", "Middle", "Far"])
  }

  @Test("Returns at most `limit` buildings")
  func returnsAtMostLimit() async {
    // Given
    let buildings = (1...10).map { building("Building \($0)", latitudeOffset: Double($0) * 0.0001) }
    let sut = makeNearestSUT(buildings: buildings, userLocation: userLocation)

    // When
    let result = await sut.getNearestBuildings(limit: 4)

    // Then
    guard case .success(let nearest) = result else {
      Issue.record("Expected success but got failure")
      return
    }
    #expect(nearest.map(\.building.name) == ["Building 1", "Building 2", "Building 3", "Building 4"])
  }

  @Test("Measures real distance in metres, not raw degrees")
  func measuresRealDistanceInMetres() async {
    // Given: at UNSW a degree of longitude is ~17% shorter than a degree of latitude, so
    // 0.0012° east (~111 m) is closer than 0.0011° north (~122 m), even though 0.0012 > 0.0011.
    let buildings = [
      building("North", latitudeOffset: 0.0011),
      building("East", longitudeOffset: 0.0012),
    ]
    let sut = makeNearestSUT(buildings: buildings, userLocation: userLocation)

    // When
    let result = await sut.getNearestBuildings(limit: 2)

    // Then
    guard case .success(let nearest) = result else {
      Issue.record("Expected success but got failure")
      return
    }
    #expect(nearest.map(\.building.name) == ["East", "North"])
    #expect((105...117).contains(nearest[0].distanceInMetres))
    #expect((116...128).contains(nearest[1].distanceInMetres))
  }

  @Test("Lists each building once even if the service returns duplicates")
  func removesDuplicateBuildings() async {
    // Given
    let closest = building("Closest", latitudeOffset: 0.0005)
    let buildings = [closest, closest, building("Further", latitudeOffset: 0.002)]
    let sut = makeNearestSUT(buildings: buildings, userLocation: userLocation)

    // When
    let result = await sut.getNearestBuildings(limit: 2)

    // Then
    guard case .success(let nearest) = result else {
      Issue.record("Expected success but got failure")
      return
    }
    #expect(nearest.map(\.building.name) == ["Closest", "Further"])
  }

  @Test("Fails when location permission is denied")
  func failsWhenPermissionDenied() async {
    // Given
    let sut = makeNearestSUT(
      buildings: [building("Closest", latitudeOffset: 0.0005)],
      userLocation: userLocation,
      authorizationStatus: .denied)

    // When
    let result = await sut.getNearestBuildings(limit: 3)

    // Then
    guard case .failure = result else {
      Issue.record("Expected failure but got success")
      return
    }
  }

  @Test("Fails when there is no location fix yet")
  func failsWhenNoLocationFix() async {
    // Given
    let sut = makeNearestSUT(
      buildings: [building("Closest", latitudeOffset: 0.0005)],
      userLocation: nil)

    // When
    let result = await sut.getNearestBuildings(limit: 3)

    // Then
    guard case .failure = result else {
      Issue.record("Expected failure but got success")
      return
    }
  }

  @Test("Fails when buildings can't be loaded")
  func failsWhenBuildingsFailToLoad() async {
    // Given
    let stubLoader = StubBuildingLoader()
    stubLoader.fetchReturnValue = .failure(.connectivity)
    let sut = makeNearestSUT(loader: stubLoader, userLocation: userLocation)

    // When
    let result = await sut.getNearestBuildings(limit: 3)

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
  private func building(_ name: String, latitudeOffset: Double = 0, longitudeOffset: Double = 0) -> Building {
    Building(
      name: name,
      id: "K-\(name)",
      latitude: userLocation.latitude + latitudeOffset,
      longitude: userLocation.longitude + longitudeOffset,
      aliases: [])
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
