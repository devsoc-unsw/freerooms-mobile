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
  ///
  /// > Important:
  /// > A reversed ``SortOptions`` vs one that contains reversed rules are not equal to each other,
  /// > even if they behave the same.
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

      private init(_ _case: _Case, isAscending: Bool = true) {
        self._case = _case
        self.isAscending = isAscending
      }

      // MARK: Public

      /// Buildings with more rooms are preferred
      public static var mostAvailable: Option { .init(.mostAvailable) }
      /// Buildings sorted in alphabetical order
      public static var alphabetical: Option { .init(.alphabetical) }
      /// Buildings in lower campus are preferred
      public static var campus: Option { .init(.campus) }

      /// Whether the option is treated as ascending or descending
      ///
      /// For example when this is disabled, the ``alphabetical`` option will search in
      /// reversed alpabetical order.
      public var isAscending: Bool = true

      /// Buildings closest to the provided location
      public static func nearest(to location: CLLocationCoordinate2D) -> Option { .init(.nearest(location)) }

      /// Returns a reversed version of the ``Option``
      public func reversed() -> Option {
        var copy = self
        copy.isAscending.toggle()
        return copy
      }

      /// Reverses the ``Option``
      ///
      /// Same as
      /// ```swift
      /// option.isReversed.toggle()
      /// ```
      mutating public func reverse() {
        isAscending.toggle()
      }

      // MARK: Internal

      enum _Case {
        case mostAvailable
        case nearest(CLLocationCoordinate2D)
        case alphabetical
        case campus
      }

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

        return isAscending ? result : result.reversed()
      }

      // MARK: Private

      private var _case: _Case

    }

    /// Same as ``Option/mostAvailable``
    public static var mostAvailable: SortOptions { SortOptions(.mostAvailable) }
    /// Same as ``Option/alphabetical``
    public static var alphabetical: SortOptions { SortOptions(.alphabetical) }
    /// Same as ``Option/campus``
    public static var campus: SortOptions { SortOptions(.campus) }

    /// Whether the options are treated as reversed
    ///
    /// For example when this is disabled, the ``alphabetical`` option will search in
    /// reversed alpabetical order.
    ///
    /// > Important:
    /// > The rules are still evaluated in the same order, only their comparison results are reversed
    public var isAscending: Bool = true

    /// Same as ``Option/nearest(to:)``
    public static func nearest(to coordinate: CLLocationCoordinate2D) -> SortOptions {
      SortOptions(.nearest(to: coordinate))
    }

    public func reversed() -> SortOptions {
      var copy = self
      copy.isAscending.toggle()
      return copy
    }

    mutating public func reverse() {
      isAscending.toggle()
    }

    /// Sort the provided buildings
    public func sort(_ buildings: borrowing some Sequence<Building>) -> [Building] {
      // Must be a strict weak order
      switch _storage {
      case .none:
        buildings.map(\.self)

      case .single(let option):
        buildings.sorted {
          let result = option.compare($0, $1)
          switch result {
          case .orderedDescending: return !isAscending
          case .orderedAscending: return isAscending
          case .orderedSame: return false
          @unknown default:
            result.reportUnknownCase()
          }
        }

      case .multiple(let options):
        buildings.sorted {
          for option in options {
            let result = option.compare($0, $1)
            switch result {
            case .orderedDescending: return !isAscending
            case .orderedAscending: return isAscending
            case .orderedSame: continue
            @unknown default:
              result.reportUnknownCase()
            }
          }
          return false
        }
      }
    }

    // MARK: Internal

    /// The stored sorting option
    ///
    /// This is used as an optimisation, as a single sort option is the most common case.
    enum _Storage {
      case none
      case single(Option)
      case multiple([Option])
    }

    // MARK: Private

    private var _storage: _Storage

  }
}

extension ComparisonResult {
  fileprivate func reversed() -> ComparisonResult {
    switch self {
    case .orderedAscending:
      return .orderedDescending
    case .orderedDescending:
      return .orderedAscending
    case .orderedSame:
      return .orderedSame
    @unknown default:
      reportUnknownCase()
    }
  }

  fileprivate func reportUnknownCase(
    file: StaticString = #file,
    line: UInt = #line,
    function: StaticString = #function)
    -> Never
  {
    preconditionFailure("\(function): Unknown case for ComparisonResult: \(self)", file: file, line: line)
  }
}

// MARK: - Building.SortOptions.Option._Case + Equatable

extension Building.SortOptions.Option._Case: Equatable {

  static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.mostAvailable, .mostAvailable), (.alphabetical, .alphabetical), (.campus, .campus):
      true

    case (.nearest(let lhs), .nearest(let rhs)):
      lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude

    default:
      false
    }
  }

}

// MARK: - Building.SortOptions.Option._Case + Hashable

extension Building.SortOptions.Option._Case: Hashable {

  func hash(into hasher: inout Hasher) {
    switch self {
    case .alphabetical:
      hasher.combine(0)
    case .campus:
      hasher.combine(1)
    case .mostAvailable:
      hasher.combine(2)
    case .nearest(let coordinates):
      hasher.combine(3)
      hasher.combine(coordinates.latitude)
      hasher.combine(coordinates.longitude)
    }
  }

}

// MARK: - Building.SortOptions.Option + Equatable, Hashable

extension Building.SortOptions.Option: Equatable, Hashable { }

// MARK: - Building.SortOptions.Option + Codable

extension Building.SortOptions.Option: Codable {

  // MARK: Lifecycle

  public init(from decoder: any Decoder) throws {
    let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)

    let isAscending = try keyedContainer.decode(Bool.self, forKey: .isAscending)
    let optionString = try keyedContainer.decode(String.self, forKey: .option)

    switch optionString {
    case Self.encodedValue(for: .alphabetical):
      self.init(.alphabetical, isAscending: isAscending)

    case Self.encodedValue(for: .campus):
      self.init(.campus, isAscending: isAscending)

    case Self.encodedValue(for: .mostAvailable):
      self.init(.mostAvailable, isAscending: isAscending)

    case Self.encodedValue(for: .nearest(.init())):
      let latitude = try keyedContainer.decode(Double.self, forKey: .latitude)
      let longitude = try keyedContainer.decode(Double.self, forKey: .longitude)
      let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
      self.init(.nearest(coordinates), isAscending: isAscending)

    default:
      throw DecodingError.dataCorrupted(.init(
        codingPath: keyedContainer.codingPath,
        debugDescription: "Invalid option: \(optionString)"))
    }
  }

  // MARK: Public

  public enum CodingKeys: String, CodingKey {
    case isAscending
    case option
    case latitude
    case longitude
  }

  public func encode(to encoder: any Encoder) throws {
    var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
    try keyedContainer.encode(isAscending, forKey: .isAscending)
    try keyedContainer.encode(Self.encodedValue(for: _case), forKey: .option)

    // Encode latitiude and longitude if necessary
    if case .nearest(let coordinates) = _case {
      try keyedContainer.encode(coordinates.latitude, forKey: .latitude)
      try keyedContainer.encode(coordinates.longitude, forKey: .longitude)
    }
  }

  // MARK: Private

  private static func encodedValue(for _case: borrowing _Case) -> String {
    switch _case {
    case .alphabetical:
      "alphabetical"
    case .campus:
      "campus"
    case .mostAvailable:
      "mostAvailable"
    case .nearest:
      "nearest"
    }
  }

}

// MARK: - Building.SortOptions._Storage + Equatable

extension Building.SortOptions._Storage: Equatable {

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none):
      return true

    case (.single(let lhs), .single(let rhs)):
      return lhs == rhs

    case (.multiple(let lhs), .multiple(let rhs)):
      assert(lhs.count > 1 && rhs.count > 1)
      return lhs == rhs

    case (.multiple(let lhs), .single(let rhs)):
      assert(lhs.count > 1)
      return lhs.first == rhs && lhs.count == 1

    case (.multiple(let lhs), .none):
      assert(lhs.count > 1)
      return lhs.isEmpty

    case (.single(let lhs), .multiple(let rhs)):
      assert(rhs.count > 1)
      return lhs == rhs.first && rhs.count == 1

    case (.none, .multiple(let rhs)):
      assert(rhs.count > 1)
      return rhs.isEmpty

    case (.single, .none), (.none, .single):
      return false
    }
  }

}

// MARK: - Building.SortOptions + Equatable

extension Building.SortOptions: Equatable { }

// MARK: - Building.SortOptions + Codable

extension Building.SortOptions: Codable {

  // MARK: Lifecycle

  public init(from decoder: any Decoder) throws {
    let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
    isAscending = try keyedContainer.decode(Bool.self, forKey: .isAscending)

    let options = try keyedContainer.decode([Option].self, forKey: .options)
    switch options.count {
    case 0:
      _storage = .none
    case 1:
      _storage = .single(options.first!)
    case 2...:
      _storage = .multiple(options)
    default:
      preconditionFailure("\(#function): Received an invalid number of options: \(options.count).")
    }
  }

  // MARK: Public

  public enum CodingKeys: String, CodingKey {
    case isAscending
    case options
  }

  public func encode(to encoder: any Encoder) throws {
    var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
    try keyedContainer.encode(isAscending, forKey: .isAscending)

    switch _storage {
    case .none:
      try keyedContainer.encode([Option](), forKey: .options)
    case .single(let option):
      try keyedContainer.encode([option], forKey: .options)
    case .multiple(let options):
      try keyedContainer.encode(options, forKey: .options)
    }
  }

}
