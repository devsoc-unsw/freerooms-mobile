//
//  FilterType.swift
//  CommonUI
//
//  Created by Yanlin Li  on 8/11/2025.
//

import Foundation

public enum FilterType {
  case duration
  case date
  case roomType
  case campusLocation
  case capacity

  // MARK: Public

  public var title: String {
    switch self {
    case .duration: "Duration"
    case .date: "Date"
    case .roomType: "Room Type"
    case .campusLocation: "Campus"
    case .capacity: "Capacity"
    }
  }

  public var icon: String {
    switch self {
    case .duration: "clock.arrow.circlepath"
    case .date: "calendar"
    case .roomType: "door.left.hand.open"
    case .campusLocation: "building.2"
    case .capacity: "person.2"
    }
  }
}
