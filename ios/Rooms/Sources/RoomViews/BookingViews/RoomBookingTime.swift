//
//  File.swift
//  Rooms
//
//  Created by Yanlin Li  on 25/9/2026.
//

import Foundation

enum RoomBookingTime {
  static let timeZone: TimeZone = {
    guard let timeZone = TimeZone(identifier: "Australia/Sydney") else {
      preconditionFailure("Australia/Sydney must be a valid system time zone")
    }

    return timeZone
  }()

  static var calendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    return calendar
  }

  static var timeFormat: Date.FormatStyle {
    Date.FormatStyle(
      date: .omitted,
      time: .shortened,
      timeZone: timeZone)
  }
}
