//
//  FilterSheet.swift
//  Rooms
//
//  Created by Yanlin Li  on 7/11/2025.
//

import SwiftUI

// MARK: - FilterSheet

/// Define an enum for all filter types
enum FilterSheet: Identifiable {
  case date
  case roomType
  case duration
  case campusLocation

  var id: String {
    switch self {
    case .date: "date"
    case .roomType: "roomType"
    case .duration: "duration"
    case .campusLocation: "campusLocation"
    }
  }
}
