//
//  RoomBookingsListView.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/9/2025.
//

import CommonUI
import RoomModels
import SwiftUI

struct RoomBookingsListView: View {

  var dateComponent: DateComponents {
    Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: dateSelect)
  }

  var filteredCurrentDayBookings: [RoomBooking] {
    roomBookings
      .filter {
        Calendar.current.isDate(dateSelect, inSameDayAs: $0.start)
      }
  }

  let room: Room
  let roomBookings: [RoomBooking]
  @Binding var dateSelect: Date

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.vertical) {
        ZStack(alignment: .topLeading) {
          // Background time grid
          VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { hour in
              BookingsLayoutView(hour: hour)
                .id(hour)
            }
          }
          .padding(.trailing, 8)

          // Overlaid booking cards
          ForEach(filteredCurrentDayBookings, id: \.self) { booking in
            let start = Calendar.current.dateComponents([.hour, .minute], from: booking.start)
            let end = Calendar.current.dateComponents([.hour, .minute], from: booking.end)

            let startMinutes = (start.hour ?? 0) * 60 + (start.minute ?? 0)

            RoomBookingCardView(
              room: room,
              currentBooking: (start, end),
              bookingName: booking.name)
              .padding(.leading, 60)
              .padding(.trailing, 10)
              .offset(
                x: 0,
                y: CGFloat(startMinutes) * (40 / 60) + 2)
          }
        }
        .frame(height: 24 * 40)
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
}

#Preview {
  RoomBookingsListView(
    room: Room.exampleOne,
    roomBookings: [RoomBooking.exampleOne, RoomBooking.exampleTwo],
    dateSelect: .constant(Date()))
    .defaultTheme()
}
