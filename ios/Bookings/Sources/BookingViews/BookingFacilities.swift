//
//  BookingFacilities.swift
//  Bookings
//
//  Created by Nicole Xie  on 18/09/2026.
//

import BookingModels
import CommonUI
import SwiftUI

// MARK: - BookingFacilities

struct BookingFacilities: View {

  // MARK: Internal

  let booking: WeeklyBooking

  var body: some View {
    VStack(alignment: .leading, spacing: BookingViewLayout.facilitiesSectionSpacing) {
      HStack(alignment: .firstTextBaseline) {
        Text("Room Facilities")
          .font(.headline)
          .foregroundStyle(theme.label.primary)
          .accessibilityAddTraits(.isHeader)

        Spacer(minLength: BookingViewLayout.facilitiesHeaderMinimumSpacing)

        if facilities.count > BookingViewLayout.facilitiesPreviewCount {
          Button(showsAllFacilities ? "Show less" : "See all") {
            showsAllFacilities.toggle()
          }
          .font(.subheadline)
          .fixedSize(horizontal: true, vertical: false)
          .tint(theme.accent.primary)
          .accessibilityValue(showsAllFacilities ? "Expanded" : "Collapsed")
        }
      }

      if facilities.isEmpty {
        Text("Facility information is not available for this room.")
          .font(.subheadline)
          .foregroundStyle(theme.label.secondary)
      } else {
        LazyVGrid(
          columns: BookingViewLayout.detailColumns(for: dynamicTypeSize),
          spacing: BookingViewLayout.facilitiesGridSpacing)
        {
          ForEach(showsAllFacilities
            ? facilities
            : Array(facilities.prefix(BookingViewLayout.facilitiesPreviewCount)))
          { facility in
            VStack(spacing: BookingViewLayout.facilityContentSpacing) {
              Image(systemName: facility.symbol)
                .font(.title2)
                .frame(height: facilityIconHeight)
                .foregroundStyle(theme.accent.primary)
                .accessibilityHidden(true)
              Text(facility.name)
                .font(.subheadline)
                .foregroundStyle(theme.label.primary)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, alignment: .top)
          }
        }
      }
    }
  }

  // MARK: Private

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(Theme.self) private var theme
  @ScaledMetric(relativeTo: .title2)
  private var facilityIconHeight = BookingViewLayout.facilityIconHeight
  @State private var showsAllFacilities = false

  private var facilities: [BookingFormatting.Facility] {
    BookingFormatting.facilities(for: booking)
  }
}
