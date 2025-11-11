//
//  MockLocationService.swift
//  Location
//
//  Created by Muqueet Mohsen Chowdhury on 2/9/2025.
//

import CoreLocation
import Foundation
import Location

// MARK: - MockLocationService

public class MockLocationService: NSObject, LocationService, LocationManagerDelegate {

  // MARK: Lifecycle

  override public init() {
    super.init()
  }

  // MARK: Public

  public var onHeadingUpdate: ((CLHeading) -> Void)?

  public var onLocationUpdate: ((Location) -> Void)?

  public func locationManager(_: any LocationManager, didUpdateHeading _: CLHeading) { }

  public func locationManager(_: any LocationManager, didUpdateLocations _: [CLLocation]) { }

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
