//
//  RoomLabel.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/9/2025.
//

import CommonUI
import SwiftUI

struct RoomLabel: View {
  let leftLabel: String
  let rightLabel: String

  var body: some View {
    HStack(spacing: 2) {
      Text("\(leftLabel):")
        .font(.callout)
        .foregroundStyle(theme.accent.primary)
      Text("\(rightLabel)")
        .bold()
        .font(.headline)
        .foregroundStyle(theme.label.primary)
    }
  }

  @Environment(Theme.self) private var theme
}

#Preview {
  RoomLabel(leftLabel: "TEST:", rightLabel: "Test")
    .defaultTheme()
}
