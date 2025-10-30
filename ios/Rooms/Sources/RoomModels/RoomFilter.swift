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
    selectedDate: Date? = nil,
    selectedStartTime: Date? = nil,
    selectedRoomTypes: Set<RoomType> = [],
    selectedDuration: Duration? = nil,
    selectedCampusLocation: CampusLocation? = nil,
    selectedCapacity: Int? = nil)
  {
    self.selectedDate = selectedDate
    self.selectedStartTime = selectedStartTime
    self.selectedRoomTypes = selectedRoomTypes
    self.selectedDuration = selectedDuration
    self.selectedCampusLocation = selectedCampusLocation
    self.selectedCapacity = selectedCapacity
  }

  // MARK: Public

  public var selectedDate: Date?
  public var selectedStartTime: Date?
  public var selectedRoomTypes: Set<RoomType>
  public var selectedDuration: Duration?
  public var selectedCampusLocation: CampusLocation?
  public var selectedCapacity: Int?

  /// Returns true if any filter is active
  public var hasActiveFilters: Bool {
    selectedDate != nil ||
      selectedStartTime != nil ||
      !selectedRoomTypes.isEmpty ||
      selectedDuration != nil ||
      selectedCampusLocation != nil ||
      selectedCapacity != nil
  }

  /// Clears all filters
  public mutating func clearAll() {
    selectedDate = nil
    selectedStartTime = nil
    selectedRoomTypes.removeAll()
    selectedDuration = nil
    selectedCampusLocation = nil
    selectedCapacity = nil
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
      "30 Mins"
    case .oneHour:
      "1 Hour"
    case .twoHours:
      "2 Hours"
    case .threeHours:
      "3 Hours"
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
