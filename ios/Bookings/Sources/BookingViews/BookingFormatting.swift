//
//  BookingFormatting.swift
//  Bookings
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingModels
import Foundation

enum BookingFormatting {
  static func locationDescription(for booking: WeeklyBooking) -> (String, String) {
    guard let buildingName = booking.buildingName, !buildingName.isEmpty else {
      return (booking.roomName, "")
    }

    return (booking.roomName, buildingName)
  }

  static func sectionTitle(for date: Date) -> String {
    date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
  }

  static func timeRange(for booking: WeeklyBooking, calendar _: Calendar = .current) -> String {
    let formatter = DateFormatter()

    #warning(" New feature to allow user toggle different date format")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "h:mm a"
    return "\(formatter.string(from: booking.start)) – \(formatter.string(from: booking.end))"
  }

  static func fullDate(for date: Date) -> String {
    date.formatted(.dateTime.weekday(.wide).day().month(.wide).year())
  }
}
