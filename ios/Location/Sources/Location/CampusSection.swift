//
//  CampusSection.swift
//  Location
//
//  Created by Yanlin Li  on 5/9/2025.
//

// MARK: - CampusSection

/// Represents the vertical campus section based on building numbers.
///
/// They are compared as follows:
/// ```swift
/// CampusSection.lower < CampusSection.middle < CampusSection.upper
/// ```
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

// MARK: Comparable

extension CampusSection: Comparable {

  public static func <(lhs: CampusSection, rhs: CampusSection) -> Bool {
    guard lhs != rhs else { return false }
    return switch (lhs, rhs) {
    case (.lower, _): true
    case (.middle, .upper): true
    case (.middle, .lower): false
    case (.upper, _): false
    case (.middle, .middle):
      preconditionFailure("Should have been handled by guard statement")
    }
  }

}
