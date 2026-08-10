//
//  BookingsListView.swift
//  Bookings
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingModels
import CommonUI
import RoomViews
import SwiftUI

// MARK: - BookingsListView

/// Date-grouped list that applies the shared Rooms and Buildings row treatment to bookings.
struct BookingsListView: View {

  // MARK: Internal

  let bookings: [WeeklyBooking]
  let isLoading: Bool
  @Binding var selectedBooking: WeeklyBooking?

  let onRefresh: () async -> Void

  var body: some View {
    List {
      ForEach(BookingListGrouping.groups(from: bookings, calendar: .current)) { group in
        Section {
          ForEach(group.bookings) { booking in
            GenericListRowView(
              rowHeight: $rowHeight,
              item: booking,
              items: group.bookings,
              isLoading: isLoading,
              onSelect: { selectedBooking = $0 },
              imageProvider: { _ in EmptyView() },
              content: { item in
                BookingListRowContentView(booking: item)
                  .padding(.horizontal, BookingViewLayout.bookingListRowContentHorizontalPadding)
              })
              .listRowInsets(EdgeInsets())
              .listRowSeparator(.hidden)
          }
          .padding(.vertical, BookingViewLayout.bookingsListSectionVerticalPadding)
        } header: {
          Text(BookingFormatting.sectionTitle(for: group.date))
            .textCase(.uppercase)
            .foregroundStyle(theme.label.primary)
        }
      }
    }
    .listRowInsets(EdgeInsets())
    .scrollContentBackground(.hidden)
    .background(theme.background.primary)
    .refreshable {
      await onRefresh()
    }
    .overlay(alignment: .top) {
      if isLoading {
        ProgressView()
          .padding(BookingViewLayout.refreshIndicatorPadding)
      }
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  @State private var rowHeight: CGFloat?
}

#Preview {
  BookingsListView(
    bookings: [
      WeeklyBooking(
        title: "DevSoc Weekly Meeting",
        bookingType: "BLOCK",
        roomID: "K-H6-LG03",
        roomName: "Tyree Energy Technology LG03",
        buildingID: "K-H6",
        buildingName: "Tyree Energy Technologies Building",
        start: Date(timeIntervalSince1970: 1_798_128_000),
        end: Date(timeIntervalSince1970: 1_798_135_200),
        usage: "TUSM",
        capacity: 50,
        abbreviation: "TETBLG03"),
      WeeklyBooking(
        title: "DevSoc Weekly Meeting",
        bookingType: "BLOCK",
        roomID: "K-H6-LG02",
        roomName: "Tyree Energy Technology LG03",
        buildingID: "K-H6",
        buildingName: "Tyree Energy Technologies Building",
        start: Date(timeIntervalSince1970: 1_798_128_000),
        end: Date(timeIntervalSince1970: 1_798_135_200),
        usage: "TUSM",
        capacity: 50,
        abbreviation: "TETBLG03"),
      WeeklyBooking(
        title: "DevSoc Weekly Meeting",
        bookingType: "BLOCK",
        roomID: "K-H6-LG04",
        roomName: "Tyree Energy Technology LG03",
        buildingID: "K-H6",
        buildingName: "Tyree Energy Technologies Building",
        start: Date(timeIntervalSince1970: 1_798_128_000),
        end: Date(timeIntervalSince1970: 1_798_135_200),
        usage: "TUSM",
        capacity: 50,
        abbreviation: "TETBLG03"),
    ],
    isLoading: false,
    selectedBooking: .constant(nil),
    onRefresh: { })
    .defaultTheme()
}
