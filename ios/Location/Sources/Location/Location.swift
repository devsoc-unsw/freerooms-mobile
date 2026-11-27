//
//  Location.swift
//  Location
//
//  Created by Anh Nguyen on 22/4/2025.
//

public import CoreLocation

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

  /// Whether going from `old` to `new` is worth reacting to: a location appeared or disappeared,
  /// or it moved at least `metres`. Smaller moves are treated as GPS jitter.
  public static func hasChanged(from old: Location?, to new: Location?, byAtLeast metres: Double) -> Bool {
    switch (old, new) {
    case (nil, nil):
      false
    case (let old?, let new?):
      old.distance(to: new) >= metres
    default:
      true
    }
  }

  public func distance(to other: Location) -> Double {
    clLocation.distance(from: other.clLocation)
  }

}
