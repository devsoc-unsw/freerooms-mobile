//
//  RoomBookingCardView.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/9/2025.
//

import CommonUI
import RoomModels
import SwiftUI

struct RoomBookingCardView: View {

  // MARK: Lifecycle

  public init(room: Room, booking: RoomBooking) {
    self.room = room
    self.booking = booking
    start = Calendar.current.dateComponents([.hour, .minute], from: booking.start)
    end = Calendar.current.dateComponents([.hour, .minute], from: booking.end)
    startMinutes = max((start.hour ?? 0) * 60 + (start.minute ?? 0), 9 * 60) - (60 * 9)
  }

  // MARK: Internal

  var topRadius: CGFloat {
    switch (bookingSize) {
      case .small:
          return 8
      case .medium:
        return 10
    }
  }

  var bottomRadius: CGFloat {
    switch (bookingSize) {
      case .small:
          return 8
      case .medium:
        return 10
    }
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      UnevenRoundedRectangle(
        topLeadingRadius: topRadius,
        bottomLeadingRadius: bottomRadius,
        bottomTrailingRadius: bottomRadius,
        topTrailingRadius: topRadius)
        .fill(theme.accent.primary)

      VStack(alignment: .leading, spacing: 3 * (bookingSize == .small ? 1 : 2)) {
        Text("\(time.0) - \(time.1)")
          .font(.system(size: (bookingSize == .small ? 8 : 12), weight: .medium))

        Text("\(booking.name)")
          .font(.system(size: (bookingSize == .small ? 14 : 20), weight: .medium))
      }
      .padding(.vertical, (bookingSize == .small ? 1 : 4))
      .padding(.horizontal, 10)
      .bold()
      .foregroundStyle(.white)
    }
    .frame(height: ((30 * numberTimeSlots) - 4))
    .offset(
      x: 0,
      y: CGFloat(startMinutes) + 2)
  }

  var numberTimeSlots: CGFloat {
    let startTimeMinute = start.minute ?? 0
    let startTimeHour = start.hour ?? 0
    let endTimeMinute = end.minute ?? 0
    let endTimeHour = end.hour ?? 0

    let startTotalMinutes = startTimeHour * 60 + startTimeMinute
    let endTotalMinutes = endTimeHour * 60 + endTimeMinute
    let range = abs(endTotalMinutes - startTotalMinutes)

    // Remove extra time
    let timeToRemove =
      if startTimeHour < 9, endTimeHour > 9 {
        9 * 60 - startTotalMinutes
      } else {
        0
      }
    return CGFloat((range - timeToRemove) / 30)
  }

  var time: (String, String) {
    let startTimeMinute = start.minute ?? 0
    let startTimeHour = start.hour ?? 0
    let endTimeMinute = end.minute ?? 0
    let endTimeHour = end.hour ?? 0

    return ("\(formatHour(startTimeHour, startTimeMinute))", "\(formatHour(endTimeHour, endTimeMinute))")
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private var room: Room
  private var booking: RoomBooking
  private var start: DateComponents
  private var end: DateComponents
  private let startMinutes: Int
  
  private enum BookingSize{
      case small, medium
  }

  private var bookingSize: BookingSize {
    if (numberTimeSlots == 1) {
      return .small
    } else {
      return .medium
    }
  }

  private func formatHour(_ hour: Int, _ minute: Int) -> String {
    if hour == 0 {
      "12\(minute >= 30 ? ":30" : "") AM"
    } else if hour < 12 {
      "\(hour)\(minute >= 30 ? ":30" : "") AM"
    } else if hour == 12 {
      "12\(minute >= 30 ? ":30" : "") PM"
    } else {
      "\(hour - 12)\(minute >= 30 ? ":30" : "") PM"
    }
  }

}

#Preview {
  RoomBookingCardView(
    room: Room.exampleOne,
    booking: RoomBooking.exampleOne)
    .defaultTheme()
}
