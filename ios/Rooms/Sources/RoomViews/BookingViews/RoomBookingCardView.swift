//
//  RoomBookingCardView.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/9/2025.
//

import CommonUI
import RoomModels
import SwiftUI

struct RoomBookingCardView: View {

  // MARK: Internal

  let booking: RoomBooking
  let isCompact: Bool

  var topRadius: CGFloat {
    switch bookingSize {
    case .small:
      Self.smallRadius
    case .medium:
      Self.mediumRadius
    }
  }

  var bottomRadius: CGFloat {
    switch bookingSize {
    case .small:
      Self.smallRadius
    case .medium:
      Self.mediumRadius
    }
  }

  var body: some View {
    RoomBookingCardContent(
      booking: booking,
      time: time,
      bookingSize: bookingSize,
      topRadius: topRadius,
      bottomRadius: bottomRadius)
      .contextMenu {
        ShareLink(item: booking.name) {
          Label("Share booking", systemImage: "square.and.arrow.up")
        }
      } preview: {
        RoomBookingPreviewView(
          booking: booking,
          time: time)
          .environment(theme)
      }
  }

  // MARK: Private

  private struct RoomBookingCardContent: View {

    // MARK: Internal

    let booking: RoomBooking
    let time: (String, String)
    let bookingSize: RoomBookingCardView.BookingSize
    let topRadius: CGFloat
    let bottomRadius: CGFloat

    var body: some View {
      ZStack(alignment: .topLeading) {
        UnevenRoundedRectangle(
          topLeadingRadius: topRadius,
          bottomLeadingRadius: bottomRadius,
          bottomTrailingRadius: bottomRadius,
          topTrailingRadius: topRadius)
          .fill(theme.accent.primary)

        VStack(
          alignment: .leading,
          spacing: Self.textSpacingBase * (bookingSize == .small
            ? Self.smallTextSpacingMultiplier
            : Self.mediumTextSpacingMultiplier))
        {
          Text("\(time.0) - \(time.1)")
            .font(.system(
              size: bookingSize == .small ? Self.smallTimeFontSize : Self.mediumTimeFontSize,
              weight: .medium))

          Text(booking.name)
            .font(.system(
              size: bookingSize == .small ? Self.smallNameFontSize : Self.mediumNameFontSize,
              weight: .medium))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .allowsTightening(true)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, fullHorizontalPadding)
        .bold()
        .foregroundStyle(.white)
      }
    }

    // MARK: Private

    private static let horizontalPadding: CGFloat = 10
    private static let mediumNameFontSize: CGFloat = 20
    private static let mediumTextSpacingMultiplier: CGFloat = 2
    private static let mediumTimeFontSize: CGFloat = 12
    private static let mediumVerticalPadding: CGFloat = 5
    private static let smallNameFontSize: CGFloat = 14
    private static let smallTextSpacingMultiplier: CGFloat = 1
    private static let smallTimeFontSize: CGFloat = 8
    private static let smallVerticalPadding: CGFloat = 2
    private static let textSpacingBase: CGFloat = 3

    @Environment(Theme.self) private var theme

    private var verticalPadding: CGFloat {
      bookingSize == .small ? Self.smallVerticalPadding : Self.mediumVerticalPadding
    }

    private var fullHorizontalPadding: CGFloat {
      Self.horizontalPadding
    }
  }

  private struct RoomBookingPreviewView: View {

    // MARK: Internal

    let booking: RoomBooking
    let time: (String, String)

    var body: some View {
      VStack(alignment: .leading, spacing: Self.contentSpacing) {
        Text("\(time.0) – \(time.1)")
          .font(.subheadline.weight(.medium))

        Text(booking.name)
          .font(.title3.bold())
          .fixedSize(horizontal: false, vertical: true)

        Text(booking.bookingType)
          .font(.caption)
      }
      .foregroundStyle(.white)
      .padding()
      .frame(width: Self.width, alignment: .leading)
      .background(theme.accent.primary)
      .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
    }

    // MARK: Private

    private static let contentSpacing: CGFloat = 8
    private static let cornerRadius: CGFloat = 12
    private static let width: CGFloat = 320

    @Environment(Theme.self) private var theme
  }

  private enum BookingSize {
    case small, medium
  }

  private static let mediumRadius: CGFloat = 10

  private static let smallRadius: CGFloat = 8

  @Environment(Theme.self) private var theme

  private var time: (String, String) {
    (
      booking.start.formatted(RoomBookingTime.timeFormat),
      booking.end.formatted(RoomBookingTime.timeFormat))
  }

  private var bookingSize: BookingSize {
    isCompact ? .small : .medium
  }
}

#Preview {
  RoomBookingCardView(
    booking: RoomBooking.exampleOne,
    isCompact: false)
    .defaultTheme()
}
