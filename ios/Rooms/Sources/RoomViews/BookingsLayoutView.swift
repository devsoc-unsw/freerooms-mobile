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

  var body: some View {
    HStack(alignment: .top) {
      Text(formatHour(hour))
        .frame(width: 50, height: 40, alignment: .trailing)
        .foregroundStyle(theme.accent.primary)

      VStack(spacing: 0) {
        Rectangle()
          .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
          .background(Rectangle().fill(Color.white))
          .frame(height: 20)
        Rectangle()
          .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
          .background(Rectangle().fill(Color.white))
          .frame(height: 20)
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
