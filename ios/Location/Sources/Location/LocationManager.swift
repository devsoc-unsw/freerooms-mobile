//
//  LocationManager.swift
//  Location
//
//  Created by Dicko Evaldo on 27/4/2025.
//

public import CoreLocation
import VISOR
public import VISORTestDoubles

// MARK: - LocationManager

@GenerateSpy
@GenerateStub
public protocol LocationManager: AnyObject {
  // MARK: Internal

  var delegate: (any LocationManagerDelegate)? { get set }
  @DefaultValue(CLAuthorizationStatus.notDetermined)
  var authorizationStatus: CLAuthorizationStatus { get }
  var location: Location? { get }
  var heading: CLHeading? { get }

  func requestWhenInUseAuthorization()
  func startUpdatingLocation()
  func stopUpdatingLocation()
}

// MARK: - LocationManagerDelegate

public protocol LocationManagerDelegate: NSObjectProtocol {
  func locationManagerDidChangeAuthorization(_ manager: any LocationManager)
  func locationManager(_ manager: any LocationManager, didUpdateLocations locations: [CLLocation])
  func locationManager(_ manager: any LocationManager, didUpdateHeading newHeading: CLHeading)
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

  public weak var delegate: (any LocationManagerDelegate)?

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

  public func locationManager(_: CLLocationManager, didFailWithError _: any Error) {
    location = nil
  }

  // MARK: Private

  private let locationManager: CLLocationManager

}
