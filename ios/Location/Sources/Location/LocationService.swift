//
//  LocationService.swift
//  Location
//
//  Created by Anh Nguyen on 22/4/2025.
//

import CoreLocation
import Foundation

// MARK: - LocationService

class LocationService: NSObject, LocationManagerDelegate {

  // MARK: Lifecycle

  init(locationManager: LocationManager) {
    self.locationManager = locationManager
    super.init()
    self.locationManager.delegate = self

    locationManagerDidChangeAuthorization(locationManager)
  }

  // MARK: Internal

  var currentPermissionState = LocationPermission.unrequested

  let locationManager: LocationManager

  func getCurrentLocation() throws -> Location {
    fatalError("TODO: Implement")
  }

  /// - Returns: returns true if `AuthorizationStatus` undetermined  and no undelying request, `false` if:
  ///   - A request is already pending
  ///   - The user has already granted permissions (either "when in use" or "always")
  /// - Throws: `LocationServiceError` if `authorizationStatus` is denied or restricted
  ///   - because the API doens't allow permission request if permission is denied / restricted
  func requestLocationPermissions() throws -> Bool {
    let authorizationStatus = locationManager.authorizationStatus

    guard authorizationStatus != .denied && authorizationStatus != .restricted else {
      throw LocationServiceError.locationPermissionsDenied
    }

    guard currentPermissionState != .pending else {
      return false
    }

    guard authorizationStatus != .authorizedAlways || authorizationStatus != .authorizedWhenInUse else {
      return false
    }

    currentPermissionState = .pending
    locationManager.requestWhenInUseAuthorization()
    return true
  }

  func locationManagerDidChangeAuthorization(_: LocationManager) {
    switch locationManager.authorizationStatus {
    case .authorizedWhenInUse:
      currentPermissionState = .granted
    case .denied:
      currentPermissionState = .denied
    default:
      currentPermissionState = .unrequested
    }
  }

}

// MARK: - LocationServiceError

enum LocationServiceError: Error {
  case locationPermissionsDenied
}
