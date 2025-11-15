//
//  FilterResetButton.swift
//  CommonUI
//
//  Created by Yanlin Li  on 8/11/2025.
//

import RoomViewModels
import SwiftUI

struct FilterResetButton: View {

  // MARK: Internal

  var body: some View {
    Button(action: {
      roomViewModel.clearAllFilters()
    }) {
      HStack(spacing: 6) {
        Image(systemName: "xmark.circle")
          .foregroundColor(theme.accent.primary)
          .font(.system(size: 14, weight: .medium))
        Text("Reset")
          .foregroundColor(.orange)
          .font(.system(size: 14, weight: .medium))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(Color.white)
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(theme.accent.primary, lineWidth: 1))
      .cornerRadius(6)
    }
    .frame(minWidth: 100)
  }

  // MARK: Private

  @Environment(LiveRoomViewModel.self) private var roomViewModel
  @Environment(Theme.self) private var theme
}

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return FilterResetButton()
    .environment(viewModel)
    .defaultTheme()
}
