//
//  BookingsLayoutView.swift
//  Rooms
//
//  Created by Yanlin Li  on 26/9/2025.
//

import CommonUI
import SwiftUI

struct BookingsLayoutView: View {

  // MARK: Internal

  var hour: Int

  let borderColor = Color.gray.opacity(Self.borderOpacity)

  var body: some View {
    HStack {
      Text(formatHour(hour))
        .frame(width: RoomLayoutConstants.timeLabelWidth, height: RoomLayoutConstants.slotHeight, alignment: .topTrailing)
        .foregroundStyle(theme.accent.primary)
        .overlay(
          VStack(spacing: 0) {
            Rectangle()
              .frame(height: Self.gridLineWidth)
            Spacer()
            Rectangle()
              .frame(height: Self.gridLineWidth)
          }
          .offset(x: Self.timeLabelGridLineOffset)
          .foregroundStyle(borderColor))

      VStack(spacing: 0) {
        Rectangle()
          .strokeBorder(borderColor, lineWidth: Self.gridLineWidth)
          .frame(height: Self.halfSlotHeight)

        Rectangle()
          .fill(.clear)
          .frame(height: Self.halfSlotHeight)
          .overlay(alignment: .leading) {
            Rectangle()
              .frame(width: Self.gridLineWidth)
              .foregroundStyle(borderColor)
          }
          .overlay(alignment: .bottom) {
            Rectangle()
              .frame(height: Self.gridLineWidth)
              .foregroundStyle(borderColor)
          }
          .overlay(alignment: .trailing) {
            Rectangle()
              .frame(width: Self.gridLineWidth)
              .foregroundStyle(borderColor)
          }
      }
    }
  }

  // MARK: Private

  private static let borderOpacity = 0.3
  private static let gridLineWidth: CGFloat = 1
  private static let halfSlotHeight = RoomLayoutConstants.slotHeight / 2
  private static let midnightHour = 0
  private static let twelveHourClock = 12

  /// Extends the small time-label grid ticks into the booking grid column.
  private static let timeLabelGridLineOffset: CGFloat = 8

  @Environment(Theme.self) private var theme

  private func formatHour(_ hour: Int) -> String {
    if hour == Self.midnightHour {
      "12 AM"
    } else if hour < Self.twelveHourClock {
      "\(hour) AM"
    } else if hour == Self.twelveHourClock {
      "12 PM"
    } else {
      "\(hour - Self.twelveHourClock) PM"
    }
  }

}

#Preview {
  BookingsLayoutView(hour: 1)
    .defaultTheme()
}
