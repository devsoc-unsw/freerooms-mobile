//
//  Location.swift
//  Location
//
//  Created by Anh Nguyen on 22/4/2025.
//
import CoreLocation

// MARK: - Location

public struct Location: Equatable, Sendable {
  public let latitude: Double
  public let longitude: Double

  public init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }
}

extension Location {

  public var clLocation: CLLocation {
    CLLocation(latitude: latitude, longitude: longitude)
  }

  public var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }

}
