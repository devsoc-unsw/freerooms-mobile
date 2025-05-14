//
//  MockLocationManager.swift
//  Location
//
//  Created by Dicko Evaldo on 14/5/2025.
//
import CoreLocation

class MockLocationManager: LocationManager {

  // MARK: Internal

  var requestInUseAuthorizationCallTracker = 0
  var delegate: LocationManagerDelegate?

  var authorizationStatus: CLAuthorizationStatus {
    _authorizationStatus
  }

  func requestWhenInUseAuthorization() {
    requestInUseAuthorizationCallTracker += 1
  }

  // MARK: to mock the authorization status
  func simulateAuthorizationStatus(to status: CLAuthorizationStatus) {
    _authorizationStatus = status
    delegate?.locationManagerDidChangeAuthorization?(self)
  }

  // MARK: Private

  // MARK: Mock AuthorizationStatus field
  private var _authorizationStatus = CLAuthorizationStatus.notDetermined

}
