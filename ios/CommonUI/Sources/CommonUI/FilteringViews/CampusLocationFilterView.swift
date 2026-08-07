//
//  CampusLocationFilterView.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 13/10/2025.
//

import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - CampusLocationFilterView

public struct CampusLocationFilterView: View {

  // MARK: Lifecycle

  public init(
    selectedCampusLocation: Binding<CampusLocation?>,
    onSelect: @escaping () -> Void)
  {
    _selectedCampusLocation = selectedCampusLocation
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: FilterSheetLayout.contentSpacing) {
      // Title
      Text("Campus Location")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      // Campus location options
      VStack(spacing: FilterSheetLayout.optionSpacing) {
        ForEach(CampusLocation.allCases) { location in
          CampusLocationButton(
            location: location,
            isSelected: selectedCampusLocation == location)
          {
            selectCampusLocation(location)
          }
        }
      }

      ClearButton(filterName: "Campus", clearFilter: roomViewModel.clearCampusLocationFilter, onSelect: onSelect)

      SelectButton(onSelect: onSelect)
    }
    .padding(.horizontal, FilterSheetLayout.horizontalPadding)
    .padding(.top, FilterSheetLayout.contentTopPadding)
    .padding(.bottom, FilterSheetLayout.contentBottomPadding)
    .cornerRadius(Self.sheetCornerRadius, corners: [.topLeft, .topRight])
  }

  // MARK: Private

  private static let sheetCornerRadius: CGFloat = 20

  @Binding private var selectedCampusLocation: CampusLocation?

  @Environment(LiveRoomViewModel.self) private var roomViewModel
  @Environment(Theme.self) private var theme

  private let onSelect: () -> Void

  private func selectCampusLocation(_ location: CampusLocation) {
    selectedCampusLocation = location
  }

}

// MARK: - CampusLocationButton

private struct CampusLocationButton: View {

  // MARK: Internal

  let location: CampusLocation
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(location.displayName)
        .font(.body)
        .fontWeight(.medium)
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
        .frame(height: FilterSheetLayout.optionHeight)
        .background(isSelected
          ? theme.accent.primary.opacity(Self.selectedBackgroundOpacity)
          : Color.gray.opacity(FilterSheetLayout.unselectedOptionBackgroundOpacity))
          .overlay(
            RoundedRectangle(cornerRadius: FilterSheetLayout.optionCornerRadius)
              .stroke(isSelected ? Color.orange : Color.clear, lineWidth: FilterSheetLayout.optionStrokeWidth))
          .cornerRadius(FilterSheetLayout.optionCornerRadius)
    }
    .buttonStyle(PlainButtonStyle())
  }

  // MARK: Private

  private static let selectedBackgroundOpacity = 0.1

  @Environment(Theme.self) private var theme
}

// MARK: - Preview

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return CampusLocationFilterView(selectedCampusLocation: .constant(.lower), onSelect: { })
    .defaultTheme()
    .environment(viewModel)
}
