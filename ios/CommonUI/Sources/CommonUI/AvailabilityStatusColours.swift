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
    case "free":
      Theme.light.list.green
    case "busy":
      Theme.light.list.red
    default:
      Theme.light.list.gray
    }
  }

  public var statusBackgroundColor: Color {
    switch status {
    case "free":
      Theme.light.list.greenTransparent.opacity(0.15)
    case "busy":
      Theme.light.list.redTransparent.opacity(0.54)
    default:
      Theme.light.list.grayTransparent.opacity(0.20)
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
