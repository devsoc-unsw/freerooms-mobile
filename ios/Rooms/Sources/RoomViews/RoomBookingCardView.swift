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
    startMinutes = (start.hour ?? 0) * 60 + (start.minute ?? 0) - (60 * 8)
  }

  // MARK: Internal

  var body: some View {
    ZStack(alignment: .topLeading) {
      UnevenRoundedRectangle(
        topLeadingRadius: isSmallBooking ? 10 : 15,
        bottomLeadingRadius: isSmallBooking ? 10 : 15,
        bottomTrailingRadius: isSmallBooking ? 10 : 15,
        topTrailingRadius: isSmallBooking ? 10 : 15)
        .fill(theme.accent.primary)

      VStack(alignment: .leading, spacing: 2 * (isSmallBooking ? 0.5 : numberTimeSlots)) {
        Text("\(time.0) - \(time.1)")
          .font(
            isSmallBooking
              ? .system(size: 10, weight: .medium)
              : .system(size: 12, weight: .medium))

        Text("\(booking.name)")
          .font(
            isSmallBooking
              ? .system(size: 18, weight: .medium)
              : .system(size: 20, weight: .medium))
      }
      .padding(isSmallBooking ? 2 : 10)
      .padding(.horizontal, isSmallBooking ? 10 : 0)
      .bold()
      .foregroundStyle(.white)
    }
    .frame(height: (20 * numberTimeSlots) - 4)
    .offset(
      x: 0,
      y: CGFloat(startMinutes) * (40 / 60) + 2)
  }

  var numberTimeSlots: CGFloat {
    let startTimeMinute = start.minute ?? 0
    let startTimeHour = start.hour ?? 0
    let endTimeMinute = end.minute ?? 0
    let endTimeHour = end.hour ?? 0

    let startTotalMinutes = startTimeHour * 60 + startTimeMinute
    let endTotalMinutes = endTimeHour * 60 + endTimeMinute
    let range = abs(endTotalMinutes - startTotalMinutes)

    return CGFloat(range / 30)
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

  private var isSmallBooking: Bool {
    numberTimeSlots < 4
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
