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

  let borderColor = Color.gray.opacity(0.3)

  var body: some View {
    HStack {
      Text(formatHour(hour))
        .frame(width: 50, height: 40, alignment: .topTrailing)
        .foregroundStyle(theme.accent.primary)
        .overlay(
          VStack(spacing: 0) {
            Rectangle()
              .frame(height: 1)
            Spacer()
            Rectangle()
              .frame(height: 1)
          }
          .offset(x: 8)
          .foregroundStyle(borderColor))

      VStack(spacing: 0) {
        Rectangle()
          .strokeBorder(borderColor, lineWidth: 1)
          .frame(height: 20)

        Rectangle()
          .fill(.clear)
          .frame(height: 20)
          .overlay(alignment: .leading) {
            Rectangle()
              .frame(width: 1)
              .foregroundStyle(borderColor)
          }
          .overlay(alignment: .bottom) {
            Rectangle()
              .frame(height: 1)
              .foregroundStyle(borderColor)
          }
          .overlay(alignment: .trailing) {
            Rectangle()
              .frame(width: 1)
              .foregroundStyle(borderColor)
          }
      }
    }
    .id(hour)
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private func formatHour(_ hour: Int) -> String {
    if hour == 0 {
      "12 AM"
    } else if hour < 12 {
      "\(hour) AM"
    } else if hour == 12 {
      "12 PM"
    } else {
      "\(hour - 12) PM"
    }
  }

}

#Preview {
  BookingsLayoutView(hour: 1)
    .defaultTheme()
}
