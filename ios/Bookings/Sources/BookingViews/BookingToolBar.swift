//
//  BookingToolBar.swift
//  Bookings
//
//  Created by Nicole Xie on 2026/10/2.
//

import CommonUI
import SwiftUI

struct BookingToolBar: View {
  
  var body: some View {
    HStack {
      Button {
        theme.toggleColorScheme(from: colorScheme)
      } label: {
        Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
          .resizable()
          .frame(width: BookingViewLayout.toolbarViewToggleIconWidth, height: BookingViewLayout.toolbarIconHeight)
      }
    }
    .padding(BookingViewLayout.toolbarIconPadding)
    .foregroundStyle(theme.accent.primary)
  }
  
  @Environment(Theme.self) private var theme
  @Environment(\.colorScheme) private var colorScheme
}
