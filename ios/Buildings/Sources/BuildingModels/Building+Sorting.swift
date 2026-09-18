//
//  Building+Sorting.swift
//  Buildings
//
//  Created by Matthew Yuen on 19/9/2026.
//

public import CoreLocation
import Location

// MARK: - Building.SortOptions

extension Building {

  /// Options to sort a collection of buildings
  ///
  /// Options specified first are preferred
  public struct SortOptions: Sendable, ExpressibleByArrayLiteral {

    // MARK: Lifecycle

    /// Create ``SortOptions`` that doesn't do any sorting
    public init() {
      _storage = .none
    }

    /// Create ``SortOptions`` from a single ``Option``
    public init(_ option: Option) {
      _storage = .single(option)
    }

    public init(arrayLiteral elements: Option...) {
      self.init(from: elements)
    }

    public init(from options: some Collection<Option>) {
      guard !options.isEmpty else {
        _storage = .none
        return
      }
      _storage = .multiple(Array(options))
    }

    // MARK: Public

    /// Options to sort a collection of buildings
    public enum Option: Sendable {
      /// Buildings with more rooms are preferred
      case mostAvailable
      /// Buildings closest to the provided location
      case nearest(CLLocationCoordinate2D)
      /// Buildings sorted in alphabetical order
      case alphabetical
      /// Buildings sorted in reverse alphabetical order
      case reverseAlphabetical
      /// Buildings in lower campus are preferred
      case lowerCampus
      /// Buildings in upper campus are preferred
      case upperCampus

      // MARK: Internal

      /// Compares the provided buildings
      func compare(_ lhs: borrowing Building, _ rhs: borrowing Building) -> ComparisonResult {
        switch self {
        case .mostAvailable:
          switch (lhs.numberOfAvailableRooms, rhs.numberOfAvailableRooms) {
          case (.none, .none):
            return .orderedSame
          case (_, .none):
            return .orderedAscending
          case (.none, _):
            return .orderedDescending
          case (.some(let lhs), .some(let rhs)):
            if lhs == rhs {
              return .orderedSame
            } else if lhs < rhs {
              return .orderedDescending
            } else {
              return .orderedAscending
            }
          }

        case .alphabetical:
          return lhs.name.localizedStandardCompare(rhs.name)

        case .reverseAlphabetical:
          return reverse(lhs.name.localizedStandardCompare(rhs.name))

        case .lowerCampus:
          let lhs = lhs.gridReference.campusSection
          let rhs = rhs.gridReference.campusSection

          if lhs == rhs {
            return .orderedSame
          } else if lhs == .lower {
            return .orderedDescending
          } else {
            return .orderedAscending
          }

        case .upperCampus:
          let lhs = lhs.gridReference.campusSection
          let rhs = rhs.gridReference.campusSection

          if lhs == rhs {
            return .orderedSame
          } else if lhs == .upper {
            return .orderedDescending
          } else {
            return .orderedAscending
          }

        case .nearest(let coordinates):
          let lhsDist = abs(coordinates.latitude - lhs.latitude) + abs(coordinates.longitude - lhs.longitude)
          let rhsDist = abs(coordinates.latitude - rhs.latitude) + abs(coordinates.longitude - rhs.longitude)

          if lhsDist == rhsDist {
            return .orderedSame
          } else if lhsDist < rhsDist {
            return .orderedAscending
          } else {
            return .orderedDescending
          }
        }
      }

    }

    public static var mostAvailable: SortOptions { SortOptions(.mostAvailable) }
    public static var alphabetical: SortOptions { SortOptions(.alphabetical) }
    public static var reverseAlphabetical: SortOptions { SortOptions(.reverseAlphabetical) }
    public static var lowerCampus: SortOptions { SortOptions(.lowerCampus) }
    public static var upperCampus: SortOptions { SortOptions(.upperCampus) }

    public static func nearest(_ coordinate: CLLocationCoordinate2D) -> SortOptions {
      SortOptions(.nearest(coordinate))
    }

    /// Sort the provided buildings
    public func sort(_ buildings: some Sequence<Building>) -> [Building] {
      switch _storage {
      case .none:
        buildings.map(\.self)
      case .single(let option):
        buildings.sorted {
          switch option.compare($0, $1) {
          case .orderedDescending: return false
          case .orderedAscending, .orderedSame: return true
          @unknown default:
            preconditionFailure()
          }
        }
      case .multiple(let options):
        buildings.sorted {
          for option in options {
            switch option.compare($0, $1) {
            case .orderedDescending: return false
            case .orderedAscending: return true
            case .orderedSame: continue
            }
          }
          return false
        }
      }
    }

    // MARK: Private

    /// The stored sorting option
    ///
    /// This is used as an optimisation, as a single sort option is the most common case.
    private enum _Storage {
      case none
      case single(Option)
      case multiple([Option])
    }

    private var _storage: _Storage

  }
}

private func reverse(_ comparisonResult: ComparisonResult) -> ComparisonResult {
  switch comparisonResult {
  case .orderedAscending:
    return .orderedDescending
  case .orderedDescending:
    return .orderedAscending
  case .orderedSame:
    return .orderedSame
  @unknown default:
    preconditionFailure()
  }
}
