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
        title: "COMP1511 Lecture",
        bookingType: "BLOCK",
        roomID: "K17-LG01",
        roomName: "Ainsworth LG01",
        buildingID: "K17",
        buildingName: "Ainsworth Building",
        start: Date(timeIntervalSince1970: 1_798_128_000),
        end: Date(timeIntervalSince1970: 1_798_135_200),
        usage: "LCTR",
        capacity: 472,
        abbreviation: "AinsworthLG01",
        accessibility: [
          "Ventilation - Air conditioning",
          "Weekend Access",
          "Wheelchair access - teaching",
          "Wheelchair access - student",
          "Power at Wall",
        ],
        audioVisual: [
          "Document camera",
        ],
        infoTechnology: [
          "Hybrid Teaching Space",
          "Lecture capture venue",
          "Lecture capture with video feed",
          "Interactive Learning Space (High Tech)",
          "IT laptop connection",
          "IT Lectern",
          "Video data projector",
        ],
        microphone: [
          "Dual Radio Microphones",
          "Lectern (fixed)",
          "Radio microphone",
        ],
        service: [],
        writingMedia: [
          "Blackboard",
          "Whiteboard",
        ]),
      WeeklyBooking(
        title: "CSE Society Workshop",
        bookingType: "BLOCK",
        roomID: "K17-G01",
        roomName: "Ainsworth G01",
        buildingID: "K17",
        buildingName: "Ainsworth Building",
        start: Date(timeIntervalSince1970: 1_798_128_000),
        end: Date(timeIntervalSince1970: 1_798_135_200),
        usage: "TUSM",
        capacity: 50,
        abbreviation: "AinsworthG01",
        accessibility: [
          "Ventilation - Air conditioning",
          "Wheelchair access - teaching",
          "Wheelchair access - student",
        ],
        audioVisual: [
          "Document camera",
        ],
        infoTechnology: [
          "IT laptop connection",
          "IT Lectern",
          "Video data projector",
          "Web Camera with Microphone",
        ],
        microphone: [
          "IT laptop connection",
          "IT Lectern",
          "Video data projector",
          "Web Camera with Microphone",
        ],
        service: [],
        writingMedia: [
          "Whiteboard",
        ]),
    ],
    isLoading: false,
    selectedBooking: .constant(nil),
    onRefresh: { })
    .defaultTheme()
}
