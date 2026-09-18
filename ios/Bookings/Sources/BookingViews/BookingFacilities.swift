//
//  BookingFacilities.swift
//  Bookings
//
//  Created by Nicole Xie  on 18/09/2026.
//

import CommonUI
import RoomModels
import SwiftUI

// MARK: - BookingFacilities

struct BookingFacilities: View {

  // MARK: Internal

  let room: Room?
  let isLoadingFacilities: Bool

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

      if room == nil, isLoadingFacilities {
        ProgressView("Loading facilities…")
          .font(.subheadline)
      } else if facilities.isEmpty {
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
                .foregroundStyle(theme.accent.primary)
                .accessibilityHidden(true)
              Text(facility.name)
                .font(.subheadline)
                .foregroundStyle(theme.label.primary)
                .multilineTextAlignment(.center)
            }
            .padding(BookingViewLayout.facilityPadding)
            .frame(maxWidth: .infinity, minHeight: BookingViewLayout.facilityMinimumHeight)
            .background(
              theme.background.secondary,
              in: RoundedRectangle(cornerRadius: BookingViewLayout.facilityCornerRadius))
          }
        }
      }
    }
  }

  // MARK: Private

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(Theme.self) private var theme
  @State private var showsAllFacilities = false

  private var facilities: [BookingFormatting.Facility] {
    BookingFormatting.facilities(for: room)
  }
}
