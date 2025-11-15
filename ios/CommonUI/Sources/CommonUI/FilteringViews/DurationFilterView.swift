//
//  DurationFilterView.swift
//  CommonUI
//
//  Created by Yanlin on 8/11/2025.
//

import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - DurationFilterView

public struct DurationFilterView: View {

  // MARK: Lifecycle

  public init(onSelect: @escaping () -> Void) {
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: 20) {
      Text("Duration")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      Picker("Duration", selection: $selectedDuration) {
        ForEach(Duration.allCases, id: \.self) { duration in
          Text(duration.displayName)
            .font(.title)
        }
      }
      .pickerStyle(.segmented)
      .scaleEffect(x: 1.0, y: 1.4)
      .frame(height: 44 * 1.4)

      Button(action: {
        // Only apply the selection when user clicks Select
        roomViewModel.selectedDuration = selectedDuration
        onSelect()
      }) {
        Text("Select")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(theme.accent.primary)
          .cornerRadius(20)
      }
    }
    .padding(.horizontal, 20)
    .onAppear {
      // Initialize with current value or default
      selectedDuration = roomViewModel.selectedDuration ?? .oneHour
    }
  }

  // MARK: Private

  @Environment(LiveRoomViewModel.self) private var roomViewModel
  @Environment(Theme.self) private var theme
  @State private var selectedDuration = Duration.oneHour

  private let onSelect: () -> Void
}

// MARK: - Preview

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return DurationFilterView(onSelect: { })
    .defaultTheme()
    .environment(viewModel)
}
