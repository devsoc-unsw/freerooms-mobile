//
//  FilterRoomOptions.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/4/2026.
//

import Foundation

// MARK: - FilterRoomOptions

public struct FilterRoomOptions: Equatable, Sendable {

  // MARK: Lifecycle

  public init(
    dateTime: String? = nil,
    startTime: String? = nil,
    endTime: String? = nil,
    buildingId: String? = nil,
    capacity: Int? = nil,
    duration: Int? = nil,
    usage: String? = nil,
    location: String? = nil,
    sortedBySpecificSchoolId: Bool = false)
  {
    self.dateTime = dateTime
    self.startTime = startTime
    self.endTime = endTime
    self.buildingId = buildingId
    self.capacity = capacity
    self.duration = duration
    self.usage = usage
    self.location = location
    self.sortedBySpecificSchoolId = sortedBySpecificSchoolId
  }

  // MARK: Public

  public let dateTime: String?
  public let startTime: String?
  public let endTime: String?
  public let buildingId: String?
  public let capacity: Int?
  public let duration: Int?
  public let usage: String?
  public let location: String?
  public let sortedBySpecificSchoolId: Bool

}

extension FilterRoomOptions {

  // MARK: Public

  /// Maps the ViewModel-facing filter fields onto the backend DTO.
  ///
  /// `selectedRoomTypes` is collapsed onto the single-valued `usage` field:
  /// - 1 selected: sends that type's raw code (e.g. `"AUD"`).
  /// - 0 or >1 selected: sends `nil` (the backend ignores it; multi-select
  ///   would need either backend support or a client-side post-filter).
  /// `CampusLocation` is intentionally NOT mapped here; it's a client-side
  /// post-filter applied via `RoomInteractor.applyClientSideFilters(...)`.
  public static func make(
    selectedDate: Date,
    selectedRoomTypes: Set<RoomType>,
    selectedDuration: Duration?,
    selectedCapacity: Int?)
    -> FilterRoomOptions
  {
    let usage = selectedRoomTypes.count == 1 ? selectedRoomTypes.first?.rawValue : nil

    return FilterRoomOptions(
      dateTime: iso8601Formatter.string(from: selectedDate),
      capacity: selectedCapacity,
      duration: selectedDuration?.rawValue,
      usage: usage)
  }

  // MARK: Private

  /// Backend requires fractional seconds (e.g. `2026-05-21T06:47:00.000Z`);
  /// without them the API responds with HTTP 400.
  private static let iso8601Formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()
}
