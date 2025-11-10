//
//  MockLocationManager.swift
//  Location
//
//  Created by Dicko Evaldo on 14/5/2025.
//
import CoreLocation
import Location

public class MockLocationManager: LocationManager {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public var heading: CLHeading?

  public var location: Location?

  public var delegate: LocationManagerDelegate?

  public var authorizationStatus: CLAuthorizationStatus {
    _authorizationStatus
  }

  public func startUpdatingLocation() { }

  public func stopUpdatingLocation() { }

  public func requestWhenInUseAuthorization() {
    requestInUseAuthorizationCallTracker += 1
  }

  // MARK: Internal

  var requestInUseAuthorizationCallTracker = 0

  // MARK: to mock the authorization status

  func simulateAuthorizationStatus(to status: CLAuthorizationStatus) {
    _authorizationStatus = status
    delegate?.locationManagerDidChangeAuthorization(self)
  }

  func simulateUserLocation(_ location: Location?) {
    self.location = location
  }

  // MARK: Private

  // MARK: Mock AuthorizationStatus field

  private var _authorizationStatus = CLAuthorizationStatus.notDetermined

}
