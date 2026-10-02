//
//  BookingFacilities.swift
//  Bookings
//
//  Created by Nicole Xie  on 18/09/2026.
//

import BookingModels
import CommonUI
import SwiftUI

// MARK: - BookingInformation

struct BookingInformation: View {

  // MARK: Internal

  let booking: WeeklyBooking

  var body: some View {
    VStack(alignment: .leading, spacing: BookingViewLayout.detailsFieldSpacing) {
      BookingDetailField(label: "Date", value: BookingFormatting.fullDate(for: booking.start))

      if BookingFormatting.spansMultipleDays(booking) {
        BookingDetailField(label: "End date", value: BookingFormatting.fullDate(for: booking.end))
      }

      LazyVGrid(
        columns: BookingViewLayout.detailColumns(for: dynamicTypeSize),
        alignment: .leading,
        spacing: BookingViewLayout.detailsFieldSpacing)
      {
        BookingDetailField(label: "Time", value: BookingFormatting.timeRange(for: booking))
        BookingDetailField(label: "Capacity", value: BookingFormatting.capacity(for: booking))
        BookingDetailField(label: "Room ID", value: booking.roomID)
        if let buildingID = booking.buildingID, !buildingID.isEmpty {
          BookingDetailField(label: "Building ID", value: buildingID)
        }
      }
    }
  }

  // MARK: Private

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
}

// MARK: - BookingDetailField

private struct BookingDetailField: View {
  let label: String
  let value: String

  var body: some View {
    VStack(alignment: .leading, spacing: BookingViewLayout.detailLabelSpacing) {
      Text(BookingFormatting.fieldLabel(label))
        .font(.caption)
        .foregroundStyle(theme.label.secondary)
      Text(value)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(theme.label.primary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(BookingFormatting.fieldAccessibilityLabel(label: label, value: value))
  }

  @Environment(Theme.self) private var theme
}
