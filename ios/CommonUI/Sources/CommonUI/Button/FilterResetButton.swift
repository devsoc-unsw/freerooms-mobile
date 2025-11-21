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
    Button(role: .destructive, action: {
      roomViewModel.clearAllFilters()
    }) {
      HStack(spacing: 6) {
        Image(systemName: "xmark.circle")
          .foregroundColor(.white)
          .font(.system(size: 14, weight: .medium))
        Text("Reset")
          .foregroundColor(.white)
          .font(.system(size: 14, weight: .medium))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(.red)
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(.white, lineWidth: 1))
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
