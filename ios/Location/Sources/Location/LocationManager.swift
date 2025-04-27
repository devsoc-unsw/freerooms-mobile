//
//  LocationManager.swift
//  Location
//
//  Created by Dicko Evaldo on 27/4/2025.
//

import CoreLocation

@objc public protocol LocationManager {
  // MARK: Internal
  var delegate: LocationManagerDelegate? { get set }
  var authorizationStatus: CLAuthorizationStatus { get }
  
  func requestWhenInUseAuthorization()
}

@objc public protocol LocationManagerDelegate: NSObjectProtocol {
  @objc optional func locationManagerDidChangeAuthorization(_ manager: LocationManager)
}
