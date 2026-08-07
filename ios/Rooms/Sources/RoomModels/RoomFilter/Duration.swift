//
//  Duration.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/5/2026.
//

import Foundation

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
