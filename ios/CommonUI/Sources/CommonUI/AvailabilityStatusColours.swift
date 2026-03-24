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

  /// Status text color derived from bookings when a custom filter is active.
  /// Falls back to the live `statusTextColour` when inactive or bookings are unavailable.
  public func contextualStatusTextColour(
    referenceInstant: Date,
    isCustomFilterActive: Bool,
    bookings: [RoomBooking]?)
    -> Color
  {
    if let isFree = isFreeFromBookings(at: referenceInstant, isCustomFilterActive: isCustomFilterActive, bookings: bookings) {
      return isFree ? Theme.light.list.green : Theme.light.list.red
    }
    return statusTextColour
  }

  /// Status background color derived from bookings when a custom filter is active.
  public func contextualStatusBackgroundColor(
    referenceInstant: Date,
    isCustomFilterActive: Bool,
    bookings: [RoomBooking]?)
    -> Color
  {
    if let isFree = isFreeFromBookings(at: referenceInstant, isCustomFilterActive: isCustomFilterActive, bookings: bookings) {
      return isFree
        ? Theme.light.list.greenTransparent.opacity(0.15)
        : Theme.light.list.redTransparent.opacity(0.54)
    }
    return statusBackgroundColor
  }
}
