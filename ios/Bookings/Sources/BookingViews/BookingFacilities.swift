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
      if groups.isEmpty {
        Text("Facility information is not available for this room.")
          .font(.subheadline)
          .foregroundStyle(theme.label.secondary)
      } else {
        ForEach(groups) { group in
          DisclosureGroup {
            LazyVGrid(
              columns: BookingViewLayout.detailColumns(for: dynamicTypeSize),
              spacing: BookingViewLayout.facilitiesGridSpacing)
            {
              ForEach(group.facilities) { facility in
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
            .padding(.top, BookingViewLayout.facilitiesSectionSpacing)
          } label: {
            Text(group.name)
              .font(.headline)
              .foregroundStyle(theme.label.primary)
              .accessibilityAddTraits(.isHeader)
          }
          .tint(theme.accent.primary)
        }
      }
    }
  }

  // MARK: Private

  private struct Facility: Identifiable {
    let name: String
    let symbol: String

    var id: String { name }
  }

  private struct FacilityGroup: Identifiable {
    let name: String
    let facilities: [Facility]

    var id: String { name }
  }

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(Theme.self) private var theme
  @ScaledMetric(relativeTo: .title2)
  private var facilityIconHeight = BookingViewLayout.facilityIconHeight

  private var groups: [FacilityGroup] {
    let groups: [(name: String, items: [String], symbol: String)] = [
      ("Accessibility", booking.accessibility, "figure.roll"),
      ("Audiovisual", booking.audioVisual, "tv"),
      ("Information Technology", booking.infoTechnology, "desktopcomputer"),
      ("Microphones", booking.microphone, "mic"),
      ("Services", booking.service, "wrench.and.screwdriver"),
      ("Writing Media", booking.writingMedia, "pencil.and.outline"),
    ]
    return groups.compactMap { group in
      let facilities = group.items.compactMap { item -> Facility? in
        let name = item.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }
        return Facility(name: name, symbol: BookingFormatting.facilitySymbol(for: name, fallback: group.symbol))
      }
      guard !facilities.isEmpty else { return nil }
      return FacilityGroup(name: group.name, facilities: facilities)
    }
  }
}
