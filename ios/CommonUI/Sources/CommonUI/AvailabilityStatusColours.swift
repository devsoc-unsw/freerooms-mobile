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
      Theme.light.list.green
    case .availableSoon:
      Theme.light.list.yellow
    case .unavailable:
      Theme.light.list.red
    case .unknown:
      Theme.light.list.gray
    }
  }

  public var statusBackgroundColor: Color {
    switch status {
    case .available:
      Theme.light.list.greenBackground.opacity(0.15)
    case .availableSoon:
      Theme.light.list.yellowBackground.opacity(0.20)
    case .unavailable:
      Theme.light.list.redBackground.opacity(0.54)
    case .unknown:
      Theme.light.list.grayBackground.opacity(0.20)
    }
  }
}
