//
//  LocationManager.swift
//  Location
//
//  Created by Dicko Evaldo on 27/4/2025.
//

import CoreLocation

// MARK: - LocationManager

public protocol LocationManager: AnyObject {
  // MARK: Internal

  var delegate: LocationManagerDelegate? { get set }
  var authorizationStatus: CLAuthorizationStatus { get }
  var location: Location? { get }
  var heading: CLHeading? { get }

  func requestWhenInUseAuthorization()
  func startUpdatingLocation()
  func stopUpdatingLocation()
}

// MARK: - LocationManagerDelegate

public protocol LocationManagerDelegate: NSObjectProtocol {
  func locationManagerDidChangeAuthorization(_ manager: LocationManager)
  func locationManager(_: LocationManager, didUpdateLocations locations: [CLLocation])
  func locationManager(_ manager: LocationManager, didUpdateHeading newHeading: CLHeading)
}

// MARK: - LiveLocationManager

public final class LiveLocationManager: NSObject, LocationManager, CLLocationManagerDelegate {

  // MARK: Lifecycle

  override public init() {
    locationManager = CLLocationManager()
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
  }

  // MARK: Public

  public var location: Location?
  public var heading: CLHeading?

  public weak var delegate: LocationManagerDelegate?

  public var authorizationStatus: CLAuthorizationStatus {
    locationManager.authorizationStatus
  }

  public func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }

  public func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
  }

  public func requestWhenInUseAuthorization() {
    locationManager.requestWhenInUseAuthorization()
  }

  /// CLLocationManagerDelegate
  public func locationManagerDidChangeAuthorization(_: CLLocationManager) {
    delegate?.locationManagerDidChangeAuthorization(self)
  }

  public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let clLocation = locations.last else {
      location = nil
      return
    }

    location = Location(
      latitude: clLocation.coordinate.latitude,
      longitude: clLocation.coordinate.longitude)

    delegate?.locationManager(self, didUpdateLocations: locations)
  }

  public func locationManager(_: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    heading = newHeading

    delegate?.locationManager(self, didUpdateHeading: newHeading)
  }

  public func locationManager(_: CLLocationManager, didFailWithError _: Error) {
    location = nil
  }

  // MARK: Private

  private let locationManager: CLLocationManager

}
