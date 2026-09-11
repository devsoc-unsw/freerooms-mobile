//
//  BookingDetailsSheet.swift
//  Bookings
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingModels
import CommonUI
import RoomViews
import SwiftUI

// MARK: - BookingDetailsSheet

/// Informational booking details built entirely from the already-loaded weekly feed model.
struct BookingDetailsSheet: View {

  // MARK: Internal

  let booking: WeeklyBooking

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: BookingViewLayout.detailsSectionSpacing) {
          Text(booking.title)
            .font(.title2.bold())
            .foregroundStyle(theme.label.primary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

          RoomImage[booking.roomID]
            .aspectRatio(contentMode: .fill)
            .frame(height: BookingViewLayout.detailsImageHeight)
            .clipShape(RoundedRectangle(cornerRadius: BookingViewLayout.detailsImageRadius))

          detailsSection(title: "When", systemImage: "calendar") {
            BookingDetailField(label: "Date", value: BookingFormatting.fullDate(for: booking.start))
            BookingDetailField(label: "Period", value: BookingFormatting.timeRange(for: booking))
          }

          detailsSection(title: "Room", systemImage: "door.left.hand.closed") {
            BookingDetailField(label: "Name", value: booking.roomName)
            BookingDetailField(label: "Room ID", value: booking.roomID)
          }

          if let buildingName = booking.buildingName, !buildingName.isEmpty {
            detailsSection(title: "Building", systemImage: "building.2") {
              BookingDetailField(label: "Name", value: buildingName)
              if let buildingID = booking.buildingID, !buildingID.isEmpty {
                BookingDetailField(label: "Building ID", value: buildingID)
              }
            }
          }
        }
        .padding(BookingViewLayout.detailsPadding)
      }
      .background(theme.background.primary)
      .navigationTitle("Booking Details")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") {
            dismiss()
          }
          .accessibilityHint("Closes booking details")
        }
      }
    }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss
  @Environment(Theme.self) private var theme

  private func detailsSection(
    title: String,
    systemImage: String,
    @ViewBuilder content: () -> some View)
    -> some View
  {
    VStack(alignment: .leading, spacing: BookingViewLayout.detailsFieldSpacing) {
      Label(title, systemImage: systemImage)
        .font(.headline)
        .foregroundStyle(theme.accent.primary)

      content()
      Divider()
    }
    .padding(.horizontal, BookingViewLayout.detailsCardHorizontalPadding)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: BookingViewLayout.detailsCornerRadius)
        .fill(theme.background.secondary))
  }
}

// MARK: - BookingDetailField

private struct BookingDetailField: View {
  let label: String
  let value: String

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(label)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .multilineTextAlignment(.trailing)
        .foregroundStyle(theme.label.primary)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("\(label), \(value)")
  }

  @Environment(Theme.self) private var theme
}

#Preview {
  BookingDetailsSheet(
    booking: WeeklyBooking(
      title: "DevSoc Weekly Meeting",
      bookingType: "BLOCK",
      roomID: "K-H6-LG03",
      roomName: "Tyree Energy Technology LG03",
      buildingID: "K-H6",
      buildingName: "Tyree Energy Technologies Building",
      start: Date(timeIntervalSince1970: 1_798_128_000),
      end: Date(timeIntervalSince1970: 1_798_195_200),
      usage: "TUSM",
      capacity: 50,
      abbreviation: "TETBLG03"))
    .defaultTheme()
}
