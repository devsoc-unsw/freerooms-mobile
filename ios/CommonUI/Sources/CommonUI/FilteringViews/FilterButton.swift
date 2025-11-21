//
//  FilterButton.swift
//  CommonUI
//
//  Created by Yanlin Li  on 8/11/2025.
//

import RoomViewModels
import RoomModels
import SwiftUI

public struct FilterButton: View {

  // MARK: Lifecycle

  public init(
    filterType: FilterType,
    showingFilter: Binding<Bool>)
  {
    self.filterType = filterType
    _showingFilter = showingFilter
  }

  // MARK: Public

  public var body: some View {
    Button(action: { showingFilter = true }) {
      HStack(spacing: 6) {
        Image(systemName: filterType.icon)
          .foregroundColor(textColor)
          .font(.system(size: 14, weight: .medium))

        Text(displayText)
          .foregroundColor(textColor)
          .font(.system(size: 14, weight: .medium))

        Image(systemName: "chevron.down")
          .foregroundColor(textColor)
          .font(.system(size: 10, weight: .medium))
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(backgroundColor)
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(theme.accent.primary, lineWidth: 1))
      .cornerRadius(6)
    }
    .frame(minWidth: 100)
  }

  // MARK: Private

  @Binding private var showingFilter: Bool
  @Environment(LiveRoomViewModel.self) private var roomViewModel
  @Environment(Theme.self) private var theme

  private let filterType: FilterType

  /// Computed property to check if filter is active
  private var isActive: Bool {
    switch filterType {
    case .duration:
      roomViewModel.selectedDuration != nil
    case .date:
      roomViewModel.selectedDate != DateDefaults.selectedDate
    case .roomType:
      !roomViewModel.selectedRoomTypes.isEmpty
    case .campusLocation:
      roomViewModel.selectedCampusLocation != nil
    case .capacity:
      roomViewModel.selectedCapacity != nil
    }
  }

  /// Dynamic display text based on filter type
  private var displayText: String {
    switch filterType {
    case .campusLocation:
      return roomViewModel.selectedCampusLocation?.displayName ?? "Campus"

    case .capacity:
      if let capacity = roomViewModel.selectedCapacity {
        return "\(capacity)+ people"
      }
      return "Capacity"

    default:
      return filterType.title
    }
  }

  private var textColor: Color {
    isActive ? .white : theme.accent.primary
  }

  private var backgroundColor: Color {
    isActive ? theme.accent.primary : .white
  }
}

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return FilterButton(filterType: FilterType.duration, showingFilter: .constant(false))
    .environment(viewModel)
    .defaultTheme()
}
