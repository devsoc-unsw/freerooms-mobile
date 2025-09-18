//
//  RoomBookingBar.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/9/2025.
//

import RoomModels
import SwiftUI

// MARK: - RoomBookingBar

public struct RoomBookingBarView: View {
  let roomBookings: [RoomBooking]
  let hour: Int
  @Binding var dateSelect: Date

  @State var bookingSet: Set<RoomBooking> = []

  public var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        Rectangle()
          .fill(isBooked(hour) ? Color.orange : Color.gray.opacity(0.2))
          .frame(height: 40)
          .border(Color.gray.opacity(0.2), width: 1)
        Text(getBookingName(hour))
          .padding(.top, 4)
          .padding(.leading, 4)
          .font(.caption)
          .foregroundStyle(.white)
      }

      ZStack(alignment: .topLeading) {
        Rectangle()
          .fill(isBooked(hour, 30) ? Color.orange : Color.gray.opacity(0.2))
          .frame(height: 40)
          .border(Color.gray.opacity(0.2), width: 1)
        Text(getBookingName(hour, 30))
          .padding(.top, 4)
          .padding(.leading, 4)
          .font(.caption)
          .foregroundStyle(.white)
      }
    }
  }

  // MARK: Internal

  var filteredCurrentDayBookings: [RoomBooking] {
    roomBookings.filter {
      Calendar.current.isDate(dateSelect, inSameDayAs: $0.start)
    }
  }

  var currentDayBookingsDateComponent: [(DateComponents, DateComponents)] {
    filteredCurrentDayBookings.map {
      (
        Calendar.current.dateComponents([.hour, .minute], from: $0.start),
        Calendar.current.dateComponents([.hour, .minute], from: $0.end))
    }
  }

  // MARK: Private

  private func isBooked(_ hour: Int, _ minute: Int = 0) -> Bool {
    if currentDayBookingsDateComponent.isEmpty {
      return false
    }

    // Convert the time slot we're checking to total minutes since midnight
    let checkTimeInMinutes = hour * 60 + minute

    // Since bookings don't overlap, we just need to find if any booking contains this time
    return currentDayBookingsDateComponent.contains { booking in
      let startHour = booking.0.hour ?? 0
      let startMinute = booking.0.minute ?? 0
      let endHour = booking.1.hour ?? 0
      let endMinute = booking.1.minute ?? 0

      let startTimeInMinutes = startHour * 60 + startMinute
      let endTimeInMinutes = endHour * 60 + endMinute

      // Check if our time slot falls within this booking's range
      // For the 30-minute slot starting at checkTimeInMinutes
      return checkTimeInMinutes >= startTimeInMinutes && checkTimeInMinutes < endTimeInMinutes
    }
  }

  private func getBookingName(_ hour: Int, _ minute: Int = 0) -> String {
    guard let booking = getStartBookingTime(hour, minute) else {
      return ""
    }

    // swiftlint:disable:next no_direct_standard_out_logs
    print("Error loading rooms: \(currentDayBookingsDateComponent)")
    return booking.name
  }

  private func getStartBookingTime(_ hour: Int, _ minute: Int) -> RoomBooking? {
    filteredCurrentDayBookings.first(where: { booking in
      let startTime = Calendar.current.dateComponents([.hour, .minute], from: booking.start)
      return startTime.hour == hour && startTime.minute == minute
    })
  }

}

#Preview {
  RoomBookingBarView(roomBookings: [], hour: 16, dateSelect: .constant(Date()))
}
