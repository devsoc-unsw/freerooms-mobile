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

public class LiveLocationManager: NSObject, LocationManager, CLLocationManagerDelegate {
    public weak var delegate: LocationManagerDelegate?
    private let clLocationManager: CLLocationManager

    public override init() {
        self.clLocationManager = CLLocationManager()
        super.init()
        self.clLocationManager.delegate = self
    }

    public var authorizationStatus: CLAuthorizationStatus {
      return clLocationManager.authorizationStatus
    }

    public func requestWhenInUseAuthorization() {
        clLocationManager.requestWhenInUseAuthorization()
    }

    // CLLocationManagerDelegate
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegate?.locationManagerDidChangeAuthorization?(self)
    }
}
