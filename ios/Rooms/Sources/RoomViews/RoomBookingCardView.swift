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

  var body: some View {
    ZStack(alignment: .topLeading) {
      UnevenRoundedRectangle(topLeadingRadius: 15, bottomLeadingRadius: 15, bottomTrailingRadius: 15, topTrailingRadius: 15)
        .fill(theme.accent.primary)

      VStack(alignment: .leading, spacing: 3 * numberTimeSlots) {
        Text("\(time.0) - \(time.1)")
          .font(.headline)

        Text("\(bookingName )")
          .font(.title)
      }
      .padding(15)
      .bold()
      .foregroundStyle(.white)
    }
    .frame(height: 20 * numberTimeSlots)
    .padding(2)
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

  var numberTimeSlots: CGFloat = 8

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
    numberTimeSlots: 8,
    room: Room.exampleOne,
    currentBooking: ( DateComponents(), DateComponents(), ), bookingName: "COMM")
    .defaultTheme()
}
