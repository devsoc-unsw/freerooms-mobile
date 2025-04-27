//
//  LocationManager.swift
//  Location
//
//  Created by Dicko Evaldo on 27/4/2025.
//

import CoreLocation

public protocol LocationManager {
  // MARK: Internal
  var delegate: CLLocationManagerDelegate? { get set }
  var authorizationStatus: CLAuthorizationStatus { get }

  func requestWhenInUseAuthorization()
}
