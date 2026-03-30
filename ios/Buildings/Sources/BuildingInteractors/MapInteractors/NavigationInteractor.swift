//
//  NavigationInteractor.swift
//  Buildings
//
//  Created by Dicko Evaldo on 16/10/2025.
//

import BuildingModels
import BuildingServices
import Location
import MapKit

extension Building {
  public var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

// MARK: - NavigationInteractor

public protocol NavigationInteractor: Sendable {
  func getRouteToBuilding(building: Building, location: Location) async throws -> MKRoute?
}

// MARK: - LiveNavigationInteractor

public final class LiveNavigationInteractor: NavigationInteractor, Sendable {

  // MARK: Lifecycle

  public init(nagivationService: NavigationService) {
    self.nagivationService = nagivationService
  }

  // MARK: Public

  public func getRouteToBuilding(building: Building, location: Location) async throws -> MKRoute? {
    try await nagivationService.getDirection(
      source: MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate)),
      destination: MKMapItem(placemark: MKPlacemark(coordinate: building.coordinate)))
  }

  // MARK: Private

  private let nagivationService: NavigationService
}

// MARK: - PreviewNavigationInteractor

public final class PreviewNavigationInteractor: NavigationInteractor, Sendable {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getRouteToBuilding(building _: BuildingModels.Building, location _: Location) async throws -> MKRoute? {
    nil
  }
}
