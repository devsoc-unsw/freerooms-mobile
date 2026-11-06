//
//  BookingFacilities.swift
//  Bookings
//
//  Created by Nicole Xie  on 18/09/2026.
//

import BookingModels
import CommonUI
import RoomModels
import RoomViews
import SwiftUI

// MARK: - BookingHeader

struct BookingHeader: View {

  // MARK: Internal

  let booking: WeeklyBooking

  var roomTypeDisplay: String? {
    RoomType(rawValue: booking.usage)?
      .displayName
  }

  var body: some View {
    let layout = dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: BookingViewLayout.detailsHeaderSpacing))
      : AnyLayout(HStackLayout(alignment: .top, spacing: BookingViewLayout.detailsHeaderSpacing))

    return layout {
      RoomImage[booking.roomID]
        .aspectRatio(contentMode: .fill)
        .frame(width: BookingViewLayout.detailsImageSize, height: BookingViewLayout.detailsImageSize)
        .clipShape(RoundedRectangle(cornerRadius: BookingViewLayout.detailsImageRadius))
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: BookingViewLayout.detailsHeaderTextSpacing) {
        Text(booking.title)
          .font(.title3.bold())
          .foregroundStyle(theme.label.primary)
          .accessibilityAddTraits(.isHeader)

        Text(booking.roomName)
          .font(.subheadline)
          .foregroundStyle(theme.label.secondary)

        Text(String(describing: roomTypeDisplay ?? booking.usage))
          .font(.subheadline)
          .foregroundStyle(theme.label.secondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  // MARK: Private

  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(Theme.self) private var theme
}
