//
//  CampusSection.swift
//  Location
//
//  Created by Yanlin Li  on 5/9/2025.
//

// MARK: - CampusSection

/// Represents the vertical campus section based on building numbers.
public enum CampusSection: Int {
  case lower, middle, upper

  // MARK: Lifecycle

  /// Creates a campus section based on building number ranges.
  /// Ranges taken from https://maps-sydney.com/maps-sydney-others/unsw-map
  /// - Parameter rawValue: Building number to classify
  public init(_ rawValue: Int) {
    switch rawValue {
    case 1...10:
      self = .lower
    case 11...18:
      self = .middle
    case 19...28:
      self = .upper
    default:
      self = .upper
    }
  }

}
