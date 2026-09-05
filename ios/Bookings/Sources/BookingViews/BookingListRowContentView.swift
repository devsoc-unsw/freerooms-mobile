//
//  BookingListRowContentView.swift
//  Bookings
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingModels
import CommonUI
import Foundation
import RoomModels
import SwiftUI

// MARK: - BookingListRowContentView

struct BookingListRowContentView: View {

  // MARK: Internal

  let booking: WeeklyBooking

  var roomTypeDisplay: String? {
    RoomType(rawValue: booking.usage)?
      .displayName
  }

  var bookingTimeRange: [String] {
    BookingFormatting.timeRange(for: booking)
      .components(separatedBy: " – ")
  }

  var body: some View {
    VStack(spacing: BookingViewLayout.rowGap) {
      HStack {
        Text(booking.title)
          .bold()
          .font(.subheadline)
          .foregroundStyle(theme.label.primary)
          .lineLimit(1)
          .truncationMode(.tail)

        Spacer()

        HStack(spacing: BookingViewLayout.rowIconGap) {
          Image(systemName: "person.2")
            .frame(width: BookingViewLayout.rowIconImageWidth)

          Text(String(booking.capacity))
        }
        .font(.caption2)
        .foregroundStyle(theme.label.primary)
        .padding(BookingViewLayout.rowCapacityCapsulePadding)
        .background(theme.accent.primary.opacity(BookingViewLayout.rowCapacityCapsuleBackgroundOpacity))
        .containerShape(.capsule)
      }

      HStack(spacing: BookingViewLayout.rowHorizontalSpacing) {
        VStack(alignment: .leading, spacing: BookingViewLayout.rowContentSpacing) {
          HStack(alignment: .top, spacing: BookingViewLayout.rowHorizontalSpacing) {
            VStack {
              Text(bookingTimeRange[0])
                .bold()
                .font(.footnote)
              Text(bookingTimeRange[1])
                .opacity(BookingViewLayout.rowEndTimeOpacity)
            }
            .font(.caption2)
            .foregroundStyle(theme.accent.primary)

            Divider()

            VStack(alignment: .leading) {
              Text(String(describing: roomTypeDisplay ?? booking.usage))
                .bold()
                .font(.subheadline)
                .foregroundStyle(theme.accent.primary)

              Divider()
                .padding(.bottom, BookingViewLayout.rowMainContentDividerBottomPadding)

              HStack(spacing: BookingViewLayout.rowIconGap) {
                Image(systemName: "door.left.hand.closed")
                  .frame(width: BookingViewLayout.rowIconImageWidth)

                Text("Room - \(BookingFormatting.locationDescription(for: booking).0)")
                  .lineLimit(1)
                  .truncationMode(.tail)
              }
              .font(.caption2)
              .foregroundStyle(theme.label.secondary)

              HStack(spacing: BookingViewLayout.rowIconGap) {
                Image(systemName: "building.2")
                  .frame(width: BookingViewLayout.rowIconImageWidth)

                Text("Building - \(BookingFormatting.locationDescription(for: booking).1)")
                  .lineLimit(1)
                  .truncationMode(.tail)
              }
              .font(.caption2)
              .foregroundStyle(theme.label.secondary)
            }
          }
          .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 0)

        Image(systemName: "chevron.right")
          .accessibilityHidden(true)
          .foregroundStyle(theme.label.secondary)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(accessibilityDescription)
      .accessibilityHint("Shows booking details")
    }
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private var accessibilityDescription: String {
    [booking.title, BookingFormatting.timeRange(for: booking), booking.roomName, booking.buildingName]
      .compactMap { $0 }
      .joined(separator: ", ")
  }

}

#Preview("Booking row") {
  BookingListRowContentView(
    booking: WeeklyBooking(
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
      abbreviation: "TETBLG03"))
    .padding()
    .defaultTheme()
}
