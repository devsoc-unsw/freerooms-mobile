//
//  CampusLocation.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/5/2026.
//

import Foundation

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
