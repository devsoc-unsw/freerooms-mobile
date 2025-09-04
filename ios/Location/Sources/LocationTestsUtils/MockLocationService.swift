//
//  MockLocationService.swift
//  Location
//
//  Created by Yanlin Li  on 5/9/2025.
//

import CoreLocation
import Location

// MARK: - MockLocationService

public class MockLocationService: LocationService {

  /// Create with mock location manager
  public override init(locationManager: LocationManager) {
    super.init(locationManager: locationManager)
  }
}
