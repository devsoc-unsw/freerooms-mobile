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

  // MARK: Lifecycle

  public init(room: Room, booking: RoomBooking) {
    self.room = room
    self.booking = booking
    start = Calendar.current.dateComponents(
      [.hour, .minute],
      from: booking.start)
    end = Calendar.current.dateComponents([.hour, .minute], from: booking.end)
    startMinutes = max(
      (start.hour ?? Self.defaultTime) * Self.minutesPerHour + (start.minute ?? Self.defaultTime),
      Self.dayStartHour * Self.minutesPerHour) - (Self.minutesPerHour * Self.dayStartHour)
  }

  // MARK: Internal

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
      bottomRadius: bottomRadius,
      isPreview: false)
      .frame(height: normalCardHeight)
      .contextMenu {
        Button("Dismiss", role: .destructive) { }
      } preview: {
        RoomBookingCardContent(
          booking: booking,
          time: time,
          bookingSize: bookingSize,
          topRadius: topRadius,
          bottomRadius: bottomRadius,
          isPreview: true)
          .frame(
            width: UIScreen.main.bounds.width - Self.contextMenuPreviewHorizontalInset,
            height: numberTimeSlots <= Self.previewExtendedHeightSlotThreshold ? extendedCardHeight : normalCardHeight)
          .environment(theme)
      }
      .offset(
        x: Self.xOffset,
        y: CGFloat(startMinutes) + Self.additionalYOffset)
  }

  // MARK: Private

  private struct RoomBookingCardContent: View {

    // MARK: Internal

    let booking: RoomBooking
    let time: (String, String)
    let bookingSize: RoomBookingCardView.BookingSize
    let topRadius: CGFloat
    let bottomRadius: CGFloat
    let isPreview: Bool

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
    private static let previewPadding: CGFloat = 8
    private static let smallNameFontSize: CGFloat = 14
    private static let smallTextSpacingMultiplier: CGFloat = 1
    private static let smallTimeFontSize: CGFloat = 8
    private static let smallVerticalPadding: CGFloat = 2
    private static let textSpacingBase: CGFloat = 3

    @Environment(Theme.self) private var theme

    private var verticalPadding: CGFloat {
      (bookingSize == .small ? Self.smallVerticalPadding : Self.mediumVerticalPadding)
        + (isPreview ? Self.previewPadding : 0)
    }

    private var fullHorizontalPadding: CGFloat {
      Self.horizontalPadding + (isPreview ? Self.previewPadding : 0)
    }
  }

  private enum BookingSize {
    case small, medium
  }

  private static let additionalYOffset: CGFloat = 2
  private static let contextMenuPreviewHorizontalInset: CGFloat = 64
  private static let dayStartHour: Int = RoomLayoutConstants.scheduleStartHour
  private static let defaultTime = 0
  private static let frameHeightOffset: CGFloat = 4
  private static let halfHourMinute = 30
  private static let mediumRadius: CGFloat = 10
  private static let midnightHour = 0
  private static let minutesPerHour: Int = 60
  private static let minutesPerSlot: Int = 30
  private static let previewExtendedHeightSlotThreshold: CGFloat = 3
  private static let previewExtraSlotCount: CGFloat = 1
  private static let smallRadius: CGFloat = 8
  private static let smallTimeSlotAmount: CGFloat = 1
  private static let twelveHourClock = 12
  private static let xOffset: CGFloat = 0

  @Environment(Theme.self) private var theme

  private var room: Room
  private var booking: RoomBooking
  private var start: DateComponents
  private var end: DateComponents
  private let startMinutes: Int

  private var numberTimeSlots: CGFloat {
    let startTimeMinute = start.minute ?? Self.defaultTime
    let startTimeHour = start.hour ?? Self.defaultTime
    let endTimeMinute = end.minute ?? Self.defaultTime
    let endTimeHour = end.hour ?? Self.defaultTime

    let startTotalMinutes = startTimeHour * Self.minutesPerHour + startTimeMinute
    let endTotalMinutes = endTimeHour * Self.minutesPerHour + endTimeMinute
    let range = abs(endTotalMinutes - startTotalMinutes)

    // Remove the part of a booking that starts before the visible schedule window.
    let timeToRemove =
      if startTimeHour < Self.dayStartHour, endTimeHour > Self.dayStartHour {
        Self.dayStartHour * Self.minutesPerHour - startTotalMinutes
      } else {
        Self.defaultTime
      }
    return CGFloat((range - timeToRemove) / Self.minutesPerSlot)
  }

  private var time: (String, String) {
    let startTimeMinute = start.minute ?? Self.defaultTime
    let startTimeHour = start.hour ?? Self.defaultTime
    let endTimeMinute = end.minute ?? Self.defaultTime
    let endTimeHour = end.hour ?? Self.defaultTime

    return (
      "\(formatHour(startTimeHour, startTimeMinute))",
      "\(formatHour(endTimeHour, endTimeMinute))")
  }

  private var bookingSize: BookingSize {
    if numberTimeSlots == Self.smallTimeSlotAmount {
      .small
    } else {
      .medium
    }
  }

  private var normalCardHeight: CGFloat {
    (CGFloat(Self.minutesPerSlot) * numberTimeSlots) - Self.frameHeightOffset
  }

  private var extendedCardHeight: CGFloat {
    (CGFloat(Self.minutesPerSlot) * (numberTimeSlots + Self.previewExtraSlotCount)) - Self.frameHeightOffset
  }

  private func formatHour(_ hour: Int, _ minute: Int) -> String {
    if hour == Self.midnightHour {
      "12\(minute >= Self.halfHourMinute ? ":30" : "") AM"
    } else if hour < Self.twelveHourClock {
      "\(hour)\(minute >= Self.halfHourMinute ? ":30" : "") AM"
    } else if hour == Self.twelveHourClock {
      "12\(minute >= Self.halfHourMinute ? ":30" : "") PM"
    } else {
      "\(hour - Self.twelveHourClock)\(minute >= Self.halfHourMinute ? ":30" : "") PM"
    }
  }

}

#Preview {
  RoomBookingCardView(
    room: Room.exampleOne,
    booking: RoomBooking.exampleOne)
    .defaultTheme()
}
