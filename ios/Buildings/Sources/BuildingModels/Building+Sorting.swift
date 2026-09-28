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
  /// Options are evaulated in the order they are specified.
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
      if options.count == 1, let first = options.first {
        _storage = .single(first)
        return
      }
      _storage = .multiple(Array(options))
    }

    // MARK: Public

    /// Options to sort a collection of buildings
    public struct Option: Sendable {

      // MARK: Lifecycle

      private init(_ _case: _Case, isReversed: Bool = false) {
        self._case = _case
        self.isReversed = isReversed
      }

      // MARK: Public

      /// Buildings with more rooms are preferred
      public static var mostAvailable: Option { .init(.mostAvailable) }
      /// Buildings sorted in alphabetical order
      public static var alphabetical: Option { .init(.alphabetical) }
      /// Buildings in lower campus are preferred
      public static var campus: Option { .init(.campus) }

      /// Whether the option is treated as reversed
      ///
      /// For example when this is enabled, the ``alphabetical`` option will search in
      /// reversed alpabetical order.
      public var isReversed: Bool = false

      /// Buildings closest to the provided location
      public static func nearest(to location: CLLocationCoordinate2D) -> Option { .init(.nearest(location)) }

      /// Returns a reversed version of the ``Option``
      public func reversed() -> Option {
        var copy = self
        copy.isReversed.toggle()
        return copy
      }

      /// Reverses the ``Option``
      ///
      /// Same as
      /// ```swift
      /// option.isReversed.toggle()
      /// ```
      mutating public func reverse() {
        isReversed.toggle()
      }

      // MARK: Internal

      /// Compares the provided buildings
      func compare(_ lhs: borrowing Building, _ rhs: borrowing Building) -> ComparisonResult {
        var result: ComparisonResult
        switch _case {
        case .mostAvailable:
          switch (lhs.numberOfAvailableRooms, rhs.numberOfAvailableRooms) {
          case (.none, .none):
            result = .orderedSame
          case (_, .none):
            result = .orderedAscending
          case (.none, _):
            result = .orderedDescending
          case (.some(let lhs), .some(let rhs)):
            if lhs == rhs {
              result = .orderedSame
            } else if lhs < rhs {
              result = .orderedDescending
            } else {
              result = .orderedAscending
            }
          }

        case .alphabetical:
          result = lhs.name.localizedStandardCompare(rhs.name)

        case .campus:
          let lhs = lhs.gridReference.campusSection
          let rhs = rhs.gridReference.campusSection

          if lhs == rhs {
            result = .orderedSame
          } else if lhs == .lower {
            result = .orderedDescending
          } else {
            result = .orderedAscending
          }

        case .nearest(let coordinates):
          let lhsDist = abs(coordinates.latitude - lhs.latitude) + abs(coordinates.longitude - lhs.longitude)
          let rhsDist = abs(coordinates.latitude - rhs.latitude) + abs(coordinates.longitude - rhs.longitude)

          if lhsDist == rhsDist {
            result = .orderedSame
          } else if lhsDist < rhsDist {
            result = .orderedAscending
          } else {
            result = .orderedDescending
          }
        }

        return isReversed ? reverseResult(result) : result
      }

      // MARK: Private

      private enum _Case {
        case mostAvailable
        case nearest(CLLocationCoordinate2D)
        case alphabetical
        case campus
      }

      private var _case: _Case

    }

    /// Same as ``Option/mostAvailable``
    public static var mostAvailable: SortOptions { SortOptions(.mostAvailable) }
    /// Same as ``Option/alphabetical``
    public static var alphabetical: SortOptions { SortOptions(.alphabetical) }
    /// Same as ``Option/campus``
    public static var campus: SortOptions { SortOptions(.campus) }

    /// Whether the option is treated as reversed
    ///
    /// For example when this is enabled, the ``alphabetical`` option will search in
    /// reversed alpabetical order.
    public var isReversed: Bool = false

    /// Same as ``Option/nearest(to:)``
    public static func nearest(to coordinate: CLLocationCoordinate2D) -> SortOptions {
      SortOptions(.nearest(to: coordinate))
    }

    public func reversed() -> SortOptions {
      var copy = self
      copy.isReversed.toggle()
      return copy
    }

    mutating public func reverse() {
      isReversed.toggle()
    }

    /// Sort the provided buildings
    public func sort(_ buildings: some Sequence<Building>) -> [Building] {
      switch _storage {
      case .none:
        buildings.map(\.self)

      case .single(let option):
        buildings.sorted {
          let result = option.compare($0, $1)
          switch result {
          case .orderedDescending: return isReversed
          case .orderedAscending, .orderedSame: return !isReversed
          @unknown default:
            reportUnknownCase(result)
          }
        }

      case .multiple(let options):
        buildings.sorted {
          for option in options {
            let result = option.compare($0, $1)
            switch result {
            case .orderedDescending: return isReversed
            case .orderedAscending: return !isReversed
            case .orderedSame: continue
            @unknown default:
              reportUnknownCase(result)
            }
          }
          return isReversed
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

private func reverseResult(_ comparisonResult: ComparisonResult) -> ComparisonResult {
  switch comparisonResult {
  case .orderedAscending:
    return .orderedDescending
  case .orderedDescending:
    return .orderedAscending
  case .orderedSame:
    return .orderedSame
  @unknown default:
    reportUnknownCase(comparisonResult)
  }
}

private func reportUnknownCase(
  _ comparisonResult: ComparisonResult,
  file: StaticString = #file,
  line: UInt = #line,
  function: StaticString = #function)
  -> Never
{
  preconditionFailure("\(function): Unknown case for ComparisonResult: \(comparisonResult)", file: file, line: line)
}
