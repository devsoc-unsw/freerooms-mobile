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

  // MARK: Internal

  private var isSmallBooking: Bool {
    numberTimeSlots < 4
  }

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
          .font(isSmallBooking
            ? .system(size: 10, weight: .medium)
            : .system(size: 12, weight: .medium))

        Text("\(bookingName)")
          .font(isSmallBooking
            ? .system(size: 18, weight: .medium)
            : .system(size: 20, weight: .medium))
      }
      .padding(isSmallBooking ? 2 : 10)
      .padding(.horizontal, isSmallBooking ? 10 : 0)
      .bold()
      .foregroundStyle(.white)
    }
    .frame(height: (20 * numberTimeSlots) - 4)
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

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

  var numberTimeSlots: CGFloat {
    let startTimeMinute = currentBooking.0.minute ?? 0
    let startTimeHour = currentBooking.0.hour ?? 0
    let endTimeMinute = currentBooking.1.minute ?? 0
    let endTimeHour = currentBooking.1.hour ?? 0

    let range = abs(endTimeHour - startTimeHour) * 60 + abs(endTimeMinute - startTimeMinute)

    return CGFloat(range / 30)
  }

  var room: Room

  var time: (String, String) {
    let startTimeMinute = currentBooking.0.minute ?? 0
    let startTimeHour = currentBooking.0.hour ?? 0
    let endTimeMinute = currentBooking.1.minute ?? 0
    let endTimeHour = currentBooking.1.hour ?? 0

    return ("\(formatHour(startTimeHour, startTimeMinute))", "\(formatHour(endTimeHour, endTimeMinute))")
  }

  var currentBooking: (DateComponents, DateComponents)
  var bookingName: String
}

#Preview {
  RoomBookingCardView(
    room: Room.exampleOne,
    currentBooking: (DateComponents(), DateComponents()), bookingName: "COMM")
    .defaultTheme()
}
