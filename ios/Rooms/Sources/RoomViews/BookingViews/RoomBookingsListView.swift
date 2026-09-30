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

  init(dateSelect: Binding<Date>) {
    _dateSelect = dateSelect
  }

  // MARK: Internal

  @Binding var dateSelect: Date

  var body: some View {
    ZStack(alignment: .topLeading) {
      if roomViewModel.getBookingsIsLoading {
        RoundedRectangle(cornerRadius: RoomLayoutConstants.bookingSectionCornerRadius)
          .fill(Color.gray.opacity(0.3))
          .frame(height: timelineLayout.totalHeight)
      }

      // Background time grid
      VStack(spacing: 0) {
        ForEach(timelineLayout.hours, id: \.self) { hour in
          BookingsLayoutView(hour: hour)
        }
      }
      .scrollTargetLayout()
      .padding(.trailing, gridTrailingPadding)

      // Overlaid booking cards
      ForEach(timelineLayout.items) { item in
        RoomBookingCardView(
          booking: item.booking,
          isCompact: item.height <= RoomLayoutConstants.slotHeight / 2)
          .frame(height: item.height)
          .offset(y: item.topOffset)
          .padding(.leading, bookingLeadingPadding)
          .padding(.trailing, bookingTrailingPadding)
      }
    }
    .frame(height: timelineLayout.totalHeight)
    .redacted(reason: roomViewModel.getBookingsIsLoading ? .placeholder : [])
  }

  // MARK: Private

  @Environment(LiveRoomViewModel.self) private var roomViewModel

  private let bookingLeadingPadding: CGFloat = 60
  private let bookingTrailingPadding: CGFloat = 10
  private let gridTrailingPadding: CGFloat = 8

  /// Room bookings layout calculations configs
  private var timelineLayout: BookingTimelineLayout {
    .roomSchedule(
      bookings: roomViewModel.currentRoomBookings,
      selectedDate: dateSelect)
  }

}

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return VStack {
    ScrollView(.vertical) {
      Text("HI")
      Spacer()
      RoomBookingsListView(
        dateSelect: .constant(Date()))
        .environment(viewModel)
        .defaultTheme()
    }
  }
}
