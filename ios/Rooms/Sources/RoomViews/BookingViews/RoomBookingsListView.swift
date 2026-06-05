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

  let hoursToDisplay: CGFloat = CGFloat(RoomLayoutConstants.scheduleEndHour - RoomLayoutConstants.scheduleStartHour)

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
    ZStack(alignment: .topLeading) {
      if roomViewModel.getBookingsIsLoading {
        RoundedRectangle(cornerRadius: RoomLayoutConstants.bookingSectionCornerRadius)
          .fill(Color.gray.opacity(0.3))
          .frame(height: CGFloat(RoomLayoutConstants.scheduleEndHour) * RoomLayoutConstants.slotHeight)
      }

      // Background time grid
      VStack(spacing: 0) {
        ForEach(RoomLayoutConstants.scheduleStartHour..<RoomLayoutConstants.scheduleEndHour, id: \.self) { hour in
          BookingsLayoutView(hour: hour)
            .id("\(hour)")
        }
      }
      .scrollTargetLayout()
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
    .frame(height: hoursToDisplay * RoomLayoutConstants.slotHeight)
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
