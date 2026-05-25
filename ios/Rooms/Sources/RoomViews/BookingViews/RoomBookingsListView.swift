//
//  RoomBookingsListView.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/9/2025.
//

import CommonUI
import RoomModels
import RoomViewModels
import SwiftUI

struct RoomBookingsListView: View {

  // MARK: Lifecycle

  public init(room: Room, roomViewModel: RoomViewModel, dateSelect: Binding<Date>) {
    self.room = room
    self.roomViewModel = roomViewModel
    _dateSelect = dateSelect
  }

  // MARK: Internal

  @Binding var dateSelect: Date

  let hoursToDisplay: CGFloat = CGFloat(RoomBookingConstants.endHour - RoomBookingConstants.startHour)
  let slotHeight: CGFloat = 60

  var dateComponent: DateComponents {
    Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: dateSelect)
  }

  var filteredCurrentDayBookings: [RoomBooking] {
    roomViewModel.currentRoomBookings
      .filter {
        Calendar.current.isDate(dateSelect, inSameDayAs: $0.start)
      }
  }

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.vertical) {
        ZStack(alignment: .topLeading) {
          if roomViewModel.getBookingsIsLoading {
            RoundedRectangle(cornerRadius: 12)
              .fill(Color.gray.opacity(0.3))
              .frame(height: 24 * slotHeight)
          }

          // Background time grid
          VStack(spacing: 0) {
            ForEach(RoomBookingConstants.startHour..<RoomBookingConstants.endHour, id: \.self) { hour in
              BookingsLayoutView(hour: hour)
                .id(hour)
            }
          }
          .padding(.trailing, 8)

          // Overlaid booking cards
          ForEach(filteredCurrentDayBookings, id: \.self) { booking in
            RoomBookingCardView(
              room: room,
              booking: booking)
              .padding(.leading, 60)
              .padding(.trailing, 10)
          }
        }
        .frame(height: hoursToDisplay * slotHeight)
      }
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .onAppear {
        let scrollHour = roomViewModel.getScrollHour(for: dateSelect)
        if Calendar.current.isDateInToday(dateSelect) {
          withAnimation(.easeInOut(duration: RoomBookingConstants.scrollAnimationDuration)) {
            proxy.scrollTo(scrollHour, anchor: .top)
          }
        } else {
          proxy.scrollTo(scrollHour, anchor: .top)
        }
      }
    }
    .redacted(reason: roomViewModel.getBookingsIsLoading ? .placeholder : [])
  }

  // MARK: Private

  private let room: Room
  private var roomViewModel: RoomViewModel

}

#Preview {
  RoomBookingsListView(
    room: Room.exampleOne,
    roomViewModel: PreviewRoomViewModel(),
    dateSelect: .constant(Date()))
    .defaultTheme()
}
