//
//  RoomFilter.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 13/10/2025.
//

import Foundation

// MARK: - RoomFilter

/// Represents the current filter state for rooms
public struct RoomFilter: Equatable {

  // MARK: Lifecycle

  public init(
    selectedDate: Date = Date(),
    selectedRoomTypes: Set<RoomType> = [],
    selectedDuration: Duration? = nil,
    selectedCampusLocation: CampusLocation? = nil,
    selectedCapacity: Int? = nil)
  {
    self.selectedDate = selectedDate
    self.selectedRoomTypes = selectedRoomTypes
    self.selectedDuration = selectedDuration
    self.selectedCampusLocation = selectedCampusLocation
    self.selectedCapacity = selectedCapacity
  }

  // MARK: Public

  public var selectedDate: Date
  public var selectedRoomTypes: Set<RoomType>
  public var selectedDuration: Duration?
  public var selectedCampusLocation: CampusLocation?
  public var selectedCapacity: Int?
}

extension RoomFilter {
  /// Start instant for duration overlap: the user’s chosen date/time if they changed the date filter from `DateDefaults.selectedDate`, otherwise `clockNow` (typically “right now”).
  public func filteringReferenceInstant(clockNow: Date = Date()) -> Date {
    selectedDate != DateDefaults.selectedDate ? selectedDate : clockNow
  }
}

// MARK: - RoomType

/// Represents different types of rooms with their display names and usage codes
public enum RoomType: String, CaseIterable, Identifiable {
  case auditorium = "AUD"
  case computerLab = "CMLB"
  case laboratory = "LAB"
  case lectureHall = "LCTR"
  case meetingRoom = "MEET"
  case studio = "SDIO"
  case tutorialRoom = "TUSM"
  case libraryStudyRoom = "LIB"

  // MARK: Public

  public var id: String { rawValue }

  public var displayName: String {
    switch self {
    case .auditorium:
      "Auditorium"
    case .computerLab:
      "Computer Lab"
    case .laboratory:
      "Laboratory"
    case .lectureHall:
      "Lecture Hall"
    case .meetingRoom:
      "Meeting Room"
    case .studio:
      "Studio"
    case .tutorialRoom:
      "Tutorial Room"
    case .libraryStudyRoom:
      "Library Study Room"
    }
  }
}

// MARK: - Duration

/// Represents available duration options for room filtering
public enum Duration: Int, CaseIterable, Identifiable {
  case thirtyMinutes = 30
  case oneHour = 60
  case twoHours = 120
  case threeHours = 180

  public var id: Int { rawValue }

  public var displayName: String {
    switch self {
    case .thirtyMinutes:
      "30m"
    case .oneHour:
      "1h"
    case .twoHours:
      "2h"
    case .threeHours:
      "3h"
    }
  }
}

// MARK: - CampusLocation

/// Represents campus location sections
public enum CampusLocation: String, CaseIterable, Identifiable {
  case upper
  case middle
  case lower

  public var id: String { rawValue }

  public var displayName: String {
    switch self {
    case .upper:
      "Upper Campus"
    case .middle:
      "Middle Campus"
    case .lower:
      "Lower Campus"
    }
  }
}

// MARK: - DateDefaults

public enum DateDefaults {
  public static var selectedDate = Date()
}
