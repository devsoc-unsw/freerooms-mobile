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
  }

  // MARK: Internal

  var currentPermissionState = LocationPermission.unrequested

  func getCurrentLocation() throws -> Location {
    fatalError("TODO: Implement")
  }

  func requestLocationPermissions() -> Bool {
    if currentPermissionState == .pending {
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

  // MARK: Private

  private var locationManager: LocationManager

}

// MARK: - LocationServiceError

enum LocationServiceError: Error {
  case locationPermissionsDenied
}
