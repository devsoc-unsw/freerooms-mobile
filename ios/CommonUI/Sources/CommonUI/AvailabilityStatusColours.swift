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

  // MARK: Public

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
      Theme.light.list.greenBackground.opacity(Self.availableBackgroundOpacity)
    case .availableSoon:
      Theme.light.list.yellowBackground.opacity(Self.warningBackgroundOpacity)
    case .unavailable:
      Theme.light.list.redBackground.opacity(Self.unavailableBackgroundOpacity)
    case .unknown:
      Theme.light.list.grayBackground.opacity(Self.warningBackgroundOpacity)
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
        ? Theme.light.list.greenBackground.opacity(Self.availableBackgroundOpacity)
        : Theme.light.list.redBackground.opacity(Self.unavailableBackgroundOpacity)
    }
    return statusBackgroundColor
  }

  // MARK: Private

  private static let availableBackgroundOpacity = 0.15
  private static let unavailableBackgroundOpacity = 0.54
  private static let warningBackgroundOpacity = 0.20
}
