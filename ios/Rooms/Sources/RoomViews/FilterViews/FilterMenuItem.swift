//
//  FilterMenuItem.swift
//  Rooms
//
//  Created by Yanlin Li on 5/7/2026.
//

import Foundation

// MARK: - RoomFilterSheet

enum RoomFilterSheet: String, Identifiable {
  case date
  case roomType
  case duration
  case campusLocation
  case capacity

  var id: String { rawValue }
}

// MARK: - FilterMenuItem

enum FilterMenuItem: CaseIterable, Identifiable {
  case date
  case duration
  case roomType
  case campusLocation
  case capacity

  // MARK: Internal

  var id: Self { self }

  var title: String {
    switch self {
    case .date:
      "Date"
    case .duration:
      "Duration"
    case .roomType:
      "Room Type"
    case .campusLocation:
      "Campus"
    case .capacity:
      "Capacity"
    }
  }

  var systemImage: String {
    switch self {
    case .date:
      "calendar"
    case .duration:
      "clock"
    case .roomType:
      "square.grid.2x2"
    case .campusLocation:
      "building.2"
    case .capacity:
      "person.2"
    }
  }

  var sheet: RoomFilterSheet {
    switch self {
    case .date:
      .date
    case .duration:
      .duration
    case .roomType:
      .roomType
    case .campusLocation:
      .campusLocation
    case .capacity:
      .capacity
    }
  }
}
