//
//  NavigationService.swift
//  Buildings
//
//  Created by Dicko Evaldo on 16/10/2025.
//

import MapKit

// MARK: - NavigationService

public protocol NavigationService: Sendable {
  func getDirection(source: MKMapItem, destination: MKMapItem) async throws -> MKRoute?
}

// MARK: - LiveNavigationService

public final class LiveNavigationService: NavigationService, Sendable {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getDirection(source: MKMapItem, destination: MKMapItem) async throws -> MKRoute? {
    let request = MKDirections.Request()
    request.source = source
    request.destination = destination
    request.transportType = .walking

    let directions = MKDirections(request: request)

    return try await directions.calculate().routes.first
  }
}

// MARK: - PreviewNavigationService

public final class PreviewNavigationService: NavigationService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getDirection(source _: MKMapItem, destination _: MKMapItem) async throws -> MKRoute? {
    nil
  }
}
