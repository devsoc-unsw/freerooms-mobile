//
//  LocationService.swift
//  Location
//
//  Created by Anh Nguyen on 22/4/2025.
//

import CoreLocation
import Foundation

// MARK: - LocationService

public protocol LocationService {
  func getCurrentLocation() throws -> Location
  func requestLocationPermissions() throws -> Bool
  func locationManagerDidChangeAuthorization(_ locationManager: LocationManager)

  var onLocationUpdate: ((Location) -> Void)? { get set }
  var onHeadingUpdate: ((CLHeading) -> Void)? { get set }
}

// MARK: - LiveLocationService

public final class LiveLocationService: NSObject, LocationService, LocationManagerDelegate {

  // MARK: Lifecycle

  public init(locationManager: LocationManager) {
    self.locationManager = locationManager
    super.init()
    locationManager.delegate = self

    // Initialize permission state by checking AuthorizationStatus are already granted/denied/unrequested
    locationManagerDidChangeAuthorization(locationManager)
  }

  // MARK: Public

  public var onHeadingUpdate: ((CLHeading) -> Void)?
  public var onLocationUpdate: ((Location) -> Void)?

  public func locationManager(_: any LocationManager, didUpdateHeading newHeading: CLHeading) {
    onHeadingUpdate?(newHeading)
  }

  public func locationManager(_: LocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let latestLocation = locations.last else { return }

    let location = Location(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)

    onLocationUpdate?(location)
  }

  public func getCurrentLocation() throws -> Location {
    guard currentPermissionState == .granted else {
      throw LocationServiceError.locationPermissionsDenied
    }

    guard let location = locationManager.location else {
      throw LocationServiceError.locationNotAvailable
    }

    return location
  }

  /// - Returns: returns true if `AuthorizationStatus` is undetermined  and no ongoing request, `false` if:
  ///   - A request is already pending
  ///   - The user has already granted permissions (either "when in use" or "always")
  /// - Throws: `LocationServiceError` if `authorizationStatus` is denied or restricted
  ///   - because the API doens't allow permission request if permission is denied / restricted
  public func requestLocationPermissions() throws -> Bool {
    let authorizationStatus = locationManager.authorizationStatus

    guard authorizationStatus != .denied, authorizationStatus != .restricted else {
      throw LocationServiceError.locationPermissionsDenied
    }

    guard currentPermissionState != .pending else {
      return false
    }

    guard authorizationStatus != .authorizedAlways, authorizationStatus != .authorizedWhenInUse else {
      return false
    }

    currentPermissionState = .pending
    locationManager.requestWhenInUseAuthorization()
    return true
  }

  public func locationManagerDidChangeAuthorization(_: LocationManager) {
    switch locationManager.authorizationStatus {
    case .authorizedWhenInUse:
      currentPermissionState = .granted

    case .denied:
      currentPermissionState = .denied

    default:
      currentPermissionState = .unrequested
    }
  }

  // MARK: Package

  package let locationManager: LocationManager

  // MARK: Internal

  var currentPermissionState = LocationPermission.unrequested
}

// MARK: - PreviewLocationService

public class PreviewLocationService: LocationService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public var onHeadingUpdate: ((CLHeading) -> Void)?

  public var onLocationUpdate: ((Location) -> Void)?

  public func requestLocationPermissions() throws -> Bool {
    true
  }

  public func locationManagerDidChangeAuthorization(_: any LocationManager) { }

  public func getCurrentLocation() throws -> Location {
    guard currentPermissionState == .granted else {
      throw LocationServiceError.locationPermissionsDenied
    }

    // Return UNSW campus center for previews
    return Location(
      latitude: -33.9173,
      longitude: 151.2312)
  }

  // MARK: Internal

  var currentPermissionState = LocationPermission.unrequested

}

// MARK: - LocationServiceError

public enum LocationServiceError: Error {
  case locationPermissionsDenied
  case locationNotAvailable
}
