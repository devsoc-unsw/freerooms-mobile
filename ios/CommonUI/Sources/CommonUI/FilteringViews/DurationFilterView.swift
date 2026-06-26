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
    VStack(spacing: 15) {
      Text("Duration")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      Picker("Duration", selection: $selectedDuration) {
        ForEach(Duration.allCases, id: \.self) { duration in
          Text(duration.displayName)
        }
      }
      .pickerStyle(.segmented)
      .frame(height: 44 * 1.4)

      ClearButton(filterName: "Duration", clearFilter: roomViewModel.clearDurationFilter, onSelect: onSelect)

      SelectButton(onSelect: onSelect)
    }
    .padding(.horizontal, 20)
    .padding(.top, FilterSheetLayout.contentTopPadding)
    .padding(.bottom, FilterSheetLayout.contentBottomPadding)
    .onAppear {
      // Initialize with current value or default
      selectedDuration = roomViewModel.selectedDuration ?? .oneHour
    }
  }

  // MARK: Private

  @Environment(LiveRoomViewModel.self) private var roomViewModel
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
