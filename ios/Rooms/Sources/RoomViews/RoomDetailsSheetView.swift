//
//  RoomDetailsSheet.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/9/2025.
//

import CommonUI
import RoomModels
import SwiftUI

struct RoomDetailsSheetView: View {

  // MARK: Internal

  @State var dateSelect = Date()

  let room: Room

  var dateComponent: DateComponents {
    Calendar.current.dateComponents([.hour, .minute], from: dateSelect)
  }

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

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        // Title
        HStack {
          Text(room.name)
            .font(.title)
            .bold()
            .foregroundStyle(theme.label.primary)

          Spacer()

          HStack {
            Image(systemName: "star.fill")
              .foregroundStyle(.yellow)
              .padding(0)

            Text("0.0")
          }
          .padding(.horizontal, 6)
          .padding(.vertical, 4)
          .overlay(
            Capsule()
              .stroke(.gray.tertiary, lineWidth: 1))
        }

        Divider()

        // Info
        HStack {
          RoomLabel(leftLabel: "ID", rightLabel: room.id)
          Spacer()
          RoomLabel(leftLabel: "Capacity", rightLabel: String(room.capacity))
        }
        RoomLabel(leftLabel: "Abbreviation", rightLabel: room.abbreviation)
        RoomLabel(leftLabel: "School", rightLabel: room.school == "" ? "UNSW" : room.school)

        Divider()

        // Bookings
        HStack {
          Text("Room Bookings")
            .font(.headline)
            .foregroundStyle(theme.label.primary)

          Spacer()

          DatePicker("Please Select a Date", selection: $dateSelect, displayedComponents: .date)
            .labelsHidden()
            .tint(theme.accent.primary)
        }

        // Scrollable booking hours
        ScrollViewReader { proxy in
          ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
              ForEach(0..<24, id: \.self) { hour in
                HStack(alignment: .top) {
                  Text(formatHour(hour))
                    .frame(width: 50, alignment: .trailing)
                    .foregroundStyle(theme.accent.primary)
                  VStack(spacing: 0) {
                    Rectangle()
                      .fill(isBooked(hour) ? Color.orange : Color.gray.opacity(0.2))
                      .frame(height: 40)
                      .border(Color.gray.opacity(0.2), width: 1)
                    Rectangle()
                      .fill(isBooked(hour, 30) ? Color.orange : Color.gray.opacity(0.2))
                      .frame(height: 40)
                      .border(Color.gray.opacity(0.2), width: 1)
                  }
                }
                .id(hour)
              }
            }
            .padding(.trailing, 8)
          }
          .frame(height: 500)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .onAppear {
            let currentHour = dateComponent.hour ?? 0
            withAnimation(.easeInOut(duration: 0.5)) {
              proxy.scrollTo(currentHour, anchor: .top)
            }
          }
        }
      }
      .padding()
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private func formatHour(_ hour: Int) -> String {
    if hour == 0 {
      "12 AM"
    } else if hour < 12 {
      "\(hour) AM"
    } else if hour == 12 {
      "12 PM"
    } else {
      "\(hour - 12) PM"
    }
  }

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

  let roomBookings: [RoomBooking]
}

#Preview {
  RoomDetailsSheetView(room: Room.exampleOne, roomBookings: [])
    .defaultTheme()
}
