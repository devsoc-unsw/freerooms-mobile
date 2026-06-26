//
//  AvailabilityStatusColours.swift
//  CommonUI
//
//  Created by Gabriella Lianti on 11/11/25.
//

import RoomModels
import SwiftUI

// MARK: - Room Status Styling

extension Room {

  public var statusTextColour: Color {
    switch status {
    case .available:
      Theme.default.list.green
    case .availableSoon:
      Theme.default.list.yellow
    case .unavailable:
      Theme.default.list.red
    case .unknown:
      Theme.default.list.gray
    }
  }

  public var statusBackgroundColor: Color {
    switch status {
    case .available:
      Theme.default.list.greenBackground.opacity(0.15)
    case .availableSoon:
      Theme.default.list.yellowBackground.opacity(0.20)
    case .unavailable:
      Theme.default.list.redBackground.opacity(0.54)
    case .unknown:
      Theme.default.list.grayBackground.opacity(0.20)
    }
  }
}
