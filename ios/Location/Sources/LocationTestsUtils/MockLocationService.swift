//
//  MockLocationService.swift
//  Location
//
//  Created by Muqueet Mohsen Chowdhury on 2/9/2025.
//

import Foundation
import Location

// MARK: - MockLocationService

public class MockLocationService: NSObject, LocationService, LocationManagerDelegate {

  // MARK: Lifecycle

  public override init() {
    super.init()
  }

  // MARK: Public

  public func getCurrentLocation() throws -> Location {
    if let stubbedError {
      throw stubbedError
    }

    return stubbedLocation ?? Location(latitude: 0.0, longitude: 0.0)
  }

  public func requestLocationPermissions() throws -> Bool {
    true
  }

  public func locationManagerDidChangeAuthorization(_: LocationManager) {
    // No-op for mock
  }

  public func stubSuccess(_ location: Location) {
    stubbedLocation = location
    stubbedError = nil
  }

  public func stubFailure(_ error: Error) {
    stubbedError = error
    stubbedLocation = nil
  }

  // MARK: Private

  private var stubbedLocation: Location?
  private var stubbedError: Error?
}
