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
      from: booking.start
    )
    end = Calendar.current.dateComponents([.hour, .minute], from: booking.end)
    startMinutes =
      max(
        (start.hour ?? defaultTime) * minutesPerHour
          + (start.minute ?? defaultTime),
        dayStartHour * minutesPerHour
      ) - (minutesPerHour * dayStartHour)
  }

  // MARK: Internal

  var topRadius: CGFloat {
    switch bookingSize {
    case .small:
      smallRadius
    case .medium:
      mediumRadius
    }
  }

  var bottomRadius: CGFloat {
    switch bookingSize {
    case .small:
      smallRadius
    case .medium:
      mediumRadius
    }
  }

  var body: some View {
    RoomBookingCardContent(
      booking: booking,
      time: time,
      bookingSize: bookingSize,
      topRadius: topRadius,
      bottomRadius: bottomRadius,
      isPreview: false
    )
    .frame(height: normalCardHeight)
    .contextMenu {
      Button("Dismiss", role: .destructive) {
      }
      //        .disabled(true)
    } preview: {
      let previewPadding: CGFloat = 64
      RoomBookingCardContent(
        booking: booking,
        time: time,
        bookingSize: bookingSize,
        topRadius: topRadius,
        bottomRadius: bottomRadius,
        isPreview: true
      )
      .frame(
        width: UIScreen.main.bounds.width - previewPadding,
        height: numberTimeSlots <= 3 ? extendedCardHeight : normalCardHeight
      )
      .environment(theme)
    }
    .offset(
      x: xOffset,
      y: CGFloat(startMinutes) + additionalYOffset
    )
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

    // Padding and spacing constants
    let smallVerticalPadding: CGFloat = 2
    let mediumVerticalPadding: CGFloat = 5
    let horizontalPadding: CGFloat = 10
    let spacingMultiplier: CGFloat = 3
    let smallSpacingMultiplier: CGFloat = 1
    let mediumSpacingMultiplier: CGFloat = 2
    let previewPadding: CGFloat = 8

    var body: some View {
      ZStack(alignment: .topLeading) {

        UnevenRoundedRectangle(
          topLeadingRadius: topRadius,
          bottomLeadingRadius: bottomRadius,
          bottomTrailingRadius: bottomRadius,
          topTrailingRadius: topRadius
        )
        .fill(theme.accent.primary)

        VStack(
          alignment: .leading,
          spacing: spacingMultiplier
            * (bookingSize == .small
              ? smallSpacingMultiplier
              : mediumSpacingMultiplier)
        ) {
          // Text size constants
          let smallTimeSize: CGFloat = 8
          let smallNameSize: CGFloat = 14
          let mediumNameSize: CGFloat = 20
          let mediumTimeSize: CGFloat = 12

          Text("\(time.0) - \(time.1)")
            .font(
              .system(
                size: bookingSize == .small ? smallTimeSize : mediumTimeSize,
                weight: .medium
              )
            )

          Text(booking.name)
            .font(
              .system(
                size: bookingSize == .small ? smallNameSize : mediumNameSize,
                weight: .medium
              )
            )
        }
        .padding(
          .vertical,
          verticalPadding
        )
        .padding(.horizontal, fullHorizontalPadding)
        .bold()
        .foregroundStyle(.white)
      }
    }

    // MARK: Private

    @Environment(Theme.self) private var theme

    private var verticalPadding: CGFloat {
      return
        (bookingSize == .small ? smallVerticalPadding : mediumVerticalPadding)
        + (isPreview ? previewPadding : 0)
    }

    private var fullHorizontalPadding: CGFloat {
      return horizontalPadding + (isPreview ? previewPadding : 0)
    }

  }

  private enum BookingSize {
    case small, medium
  }

  @Environment(Theme.self) private var theme

  // Global constants
  private let minutesPerHour: Int = 60
  private let dayStartHour: Int = 9
  private let minutesPerSlot: Int = 30
  private let defaultTime = 0

  // Card radius
  private let smallRadius: CGFloat = 8
  private let mediumRadius: CGFloat = 10

  // Booking offset
  private let additionalYOffset: CGFloat = 2
  private let frameHeightOffset: CGFloat = 4
  private let xOffset: CGFloat = 0

  private var room: Room
  private var booking: RoomBooking
  private var start: DateComponents
  private var end: DateComponents
  private let startMinutes: Int

  private let smallTimeSlotAmount: CGFloat = 1

  private var numberTimeSlots: CGFloat {
    let startTimeMinute = start.minute ?? defaultTime
    let startTimeHour = start.hour ?? defaultTime
    let endTimeMinute = end.minute ?? defaultTime
    let endTimeHour = end.hour ?? defaultTime

    let startTotalMinutes = startTimeHour * minutesPerHour + startTimeMinute
    let endTotalMinutes = endTimeHour * minutesPerHour + endTimeMinute
    let range = abs(endTotalMinutes - startTotalMinutes)

    // Remove extra time
    let timeToRemove =
      if startTimeHour < dayStartHour, endTimeHour > dayStartHour {
        dayStartHour * minutesPerHour - startTotalMinutes
      } else {
        defaultTime
      }
    return CGFloat((range - timeToRemove) / minutesPerSlot)
  }

  private var time: (String, String) {
    let startTimeMinute = start.minute ?? defaultTime
    let startTimeHour = start.hour ?? defaultTime
    let endTimeMinute = end.minute ?? defaultTime
    let endTimeHour = end.hour ?? defaultTime

    return (
      "\(formatHour(startTimeHour, startTimeMinute))",
      "\(formatHour(endTimeHour, endTimeMinute))"
    )
  }

  private var bookingSize: BookingSize {
    if numberTimeSlots == smallTimeSlotAmount {
      .small
    } else {
      .medium
    }
  }

  private var normalCardHeight: CGFloat {
    (CGFloat(minutesPerSlot) * numberTimeSlots) - frameHeightOffset
  }

  private var extendedCardHeight: CGFloat {
    (CGFloat(minutesPerSlot) * (numberTimeSlots + 1)) - frameHeightOffset
  }

  private func formatHour(_ hour: Int, _ minute: Int) -> String {
    let midnightHour = 0
    let twelveHourClock = 12
    let halfHourMinute = 30

    if hour == midnightHour {
      return "12\(minute >= halfHourMinute ? ":30" : "") AM"
    } else if hour < twelveHourClock {
      return "\(hour)\(minute >= halfHourMinute ? ":30" : "") AM"
    } else if hour == twelveHourClock {
      return "12\(minute >= halfHourMinute ? ":30" : "") PM"
    } else {
      return
        "\(hour - twelveHourClock)\(minute >= halfHourMinute ? ":30" : "") PM"
    }
  }

}

#Preview {
  RoomBookingCardView(
    room: Room.exampleOne,
    booking: RoomBooking.exampleOne
  )
  .defaultTheme()
}
