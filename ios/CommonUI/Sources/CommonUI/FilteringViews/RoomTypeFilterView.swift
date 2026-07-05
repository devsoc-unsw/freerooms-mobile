//
//  RoomTypeFilterView.swift
//  Rooms
//
//  Created by select on 13/10/2025.
//

import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - RoomTypeFilterView

public struct RoomTypeFilterView: View {

  // MARK: Lifecycle

  public init(selectedRoomTypes: Binding<Set<RoomType>>, onSelect: @escaping () -> Void) {
    _selectedRoomTypes = selectedRoomTypes
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: FilterSheetLayout.contentSpacing) {
      // Title
      Text("Room Types")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      // Room type grid
      LazyVGrid(
        columns: Array(
          repeating: GridItem(.flexible(), spacing: FilterSheetLayout.optionSpacing),
          count: FilterSheetLayout.optionColumnCount),
        spacing: FilterSheetLayout.optionSpacing)
      {
        ForEach(RoomType.allCases) { roomType in
          RoomTypeButton(
            roomType: roomType,
            isSelected: selectedRoomTypes.contains(roomType))
          {
            toggleRoomType(roomType)
          }
        }
      }

      ClearButton(
        filterName: "All Room Types",
        clearFilter: roomViewModel.clearRoomTypeFilter,
        onSelect: applyWithoutDismissing)

      SelectButton(onSelect: onSelect)
    }
    .padding(.horizontal, FilterSheetLayout.horizontalPadding)
    .padding(.top, FilterSheetLayout.contentTopPadding)
    .padding(.bottom, FilterSheetLayout.contentBottomPadding)
  }

  // MARK: Private

  @Binding private var selectedRoomTypes: Set<RoomType>
  @Environment(LiveRoomViewModel.self) private var roomViewModel

  private let onSelect: () -> Void

  private func toggleRoomType(_ roomType: RoomType) {
    if selectedRoomTypes.contains(roomType) {
      selectedRoomTypes.remove(roomType)
    } else {
      selectedRoomTypes.insert(roomType)
    }
    applyWithoutDismissing()
  }

  /// Re-runs the backend filter using the current selection but leaves the
  /// sheet open so the user can keep toggling chips and watch results update.
  private func applyWithoutDismissing() {
    Task { await roomViewModel.applyFilters() }
  }
}

// MARK: - RoomTypeButton

private struct RoomTypeButton: View {

  // MARK: Internal

  let roomType: RoomType
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(roomType.displayName)
        .font(.body)
        .fontWeight(.medium)
        .foregroundColor(isSelected ? .primary : .primary)
        .frame(maxWidth: .infinity)
        .frame(height: FilterSheetLayout.optionHeight)
        .background(isSelected
          ? theme.accent.primary.opacity(Self.selectedBackgroundOpacity)
          : Color.gray.opacity(FilterSheetLayout.unselectedOptionBackgroundOpacity))
          .overlay(
            RoundedRectangle(cornerRadius: FilterSheetLayout.optionCornerRadius)
              .stroke(
                isSelected ? Color.gray.opacity(Self.selectedStrokeOpacity) : Color.clear,
                lineWidth: FilterSheetLayout.optionStrokeWidth))
          .cornerRadius(FilterSheetLayout.optionCornerRadius)
    }
    .buttonStyle(PlainButtonStyle())
  }

  // MARK: Private

  private static let selectedBackgroundOpacity = 0.3
  private static let selectedStrokeOpacity = 0.3

  @Environment(Theme.self) private var theme
}

// MARK: - Preview

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return RoomTypeFilterView(selectedRoomTypes: .constant([.computerLab]), onSelect: { })
    .defaultTheme()
    .environment(viewModel)
}
