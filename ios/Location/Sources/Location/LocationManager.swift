//
//  LocationManager.swift
//  Location
//
//  Created by Dicko Evaldo on 27/4/2025.
//

import CoreLocation

// MARK: - LocationManager

@objc
public protocol LocationManager: AnyObject {
  // MARK: Internal
  var delegate: LocationManagerDelegate? { get set }
  var authorizationStatus: CLAuthorizationStatus { get }

  func requestWhenInUseAuthorization()
}

// MARK: - LocationManagerDelegate

@objc
public protocol LocationManagerDelegate: NSObjectProtocol {
  @objc
  optional func locationManagerDidChangeAuthorization(_ manager: LocationManager)
}

// MARK: - LiveLocationManager

public final class LiveLocationManager: NSObject, LocationManager, CLLocationManagerDelegate {

  // MARK: Lifecycle

  public override init() {
    clLocationManager = CLLocationManager()
    super.init()
    clLocationManager.delegate = self
  }

  // MARK: Public

  public weak var delegate: LocationManagerDelegate?

  public var authorizationStatus: CLAuthorizationStatus {
    clLocationManager.authorizationStatus
  }

  public func requestWhenInUseAuthorization() {
    clLocationManager.requestWhenInUseAuthorization()
  }

  /// CLLocationManagerDelegate
  public func locationManagerDidChangeAuthorization(_: CLLocationManager) {
    delegate?.locationManagerDidChangeAuthorization?(self)
  }

  // MARK: Private

  private let clLocationManager: CLLocationManager

}
