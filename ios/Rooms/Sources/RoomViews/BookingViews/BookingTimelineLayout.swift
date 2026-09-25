//
//  File.swift
//  Rooms
//
//  Created by Yanlin Li  on 25/9/2026.
//

import Foundation
import RoomModels
import SwiftUI

// MARK: - BookingTimelineLayout
struct BookingTimelineLayout {

  let bookings: [RoomBooking]
  let selectedDate: Date
  let calendar: Calendar
  let defaultStartHour: Int
  let endHour: Int
  let hourHeight: CGFloat
  let cardVerticalInset: CGFloat

  var filteredBookings: [RoomBooking] {
    let dayStart = calendar.startOfDay(for: selectedDate)

    guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
      return []
    }

    return bookings.filter { booking in
      booking.start >= dayStart &&
        booking.start < dayEnd &&
        booking.end > booking.start &&
        booking.end <= dayEnd
    }
    .sorted { first, second in
      first.start < second.start
    }
  }

  var startHour: Int {
    let earliestBookingHour = filteredBookings
      .map { calendar.component(.hour, from: $0.start) }
      .min()

    return min(defaultStartHour, earliestBookingHour ?? defaultStartHour)
  }

  var hours: [Int] {
    Array(startHour..<endHour)
  }

  var totalHeight: CGFloat {
    CGFloat(endHour - startHour) * hourHeight
  }

  var items: [Item] {
    let dayStart = calendar.startOfDay(for: selectedDate)

    guard let timelineStart = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: dayStart) else {
      return []
    }

    let pointsPerMinute = hourHeight / 60

    return filteredBookings
      .enumerated()
      .map { index, booking in
        let minutesFromTimelineStart =
          booking.start.timeIntervalSince(timelineStart) / 60

        let bookingDurationMinutes =
          booking.end.timeIntervalSince(booking.start) / 60

        let logicalTop =
          CGFloat(minutesFromTimelineStart) * pointsPerMinute

        let logicalHeight =
          CGFloat(bookingDurationMinutes) * pointsPerMinute

        return Item(
          id: index,
          booking: booking,
          topOffset: logicalTop + cardVerticalInset,
          height: max(0, logicalHeight - cardVerticalInset * 2))
      }
  }

  static func roomSchedule(
    bookings: [RoomBooking],
    selectedDate: Date)
    -> BookingTimelineLayout
  {
    BookingTimelineLayout(
      bookings: bookings,
      selectedDate: selectedDate,
      calendar: RoomBookingTime.calendar,
      defaultStartHour: RoomLayoutConstants.scheduleStartHour,
      endHour: RoomLayoutConstants.scheduleEndHour,
      hourHeight: RoomLayoutConstants.slotHeight,
      cardVerticalInset: 2)
  }

}

// MARK: - Item

struct Item: Identifiable, Hashable {
  let id: Int
  let booking: RoomBooking
  let topOffset: CGFloat
  let height: CGFloat
}
