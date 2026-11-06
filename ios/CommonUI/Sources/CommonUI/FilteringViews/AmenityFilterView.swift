//
//  AmenityFilterView.swift
//  Rooms
//
//  Created by Nicole Xie on 06/11/2026.
//

public import RoomModels
public import SwiftUI

// MARK: - AmenityFilterView

public struct AmenityFilterView: View {

  // MARK: Lifecycle

  public init(selectedAmenities: Binding<Set<RoomAmenity>>, onSelect: @escaping () -> Void) {
    _selectedAmenities = selectedAmenities
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: FilterSheetLayout.contentSpacing) {
      Text("Amenities")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      LazyVGrid(
        columns: Array(
          repeating: GridItem(.flexible(), spacing: FilterSheetLayout.optionSpacing),
          count: FilterSheetLayout.optionColumnCount),
        spacing: FilterSheetLayout.optionSpacing)
      {
        ForEach(RoomAmenity.allCases) { amenity in
          AmenityButton(
            amenity: amenity,
            isSelected: selectedAmenities.contains(amenity))
          {
            toggleAmenity(amenity)
          }
        }
      }

      ClearButton(
        filterName: "All Amenities",
        clearFilter: { selectedAmenities.removeAll() },
        onSelect: onSelect)

      SelectButton(onSelect: onSelect)
    }
    .padding(.horizontal, FilterSheetLayout.horizontalPadding)
    .padding(.top, FilterSheetLayout.contentTopPadding)
    .padding(.bottom, FilterSheetLayout.contentBottomPadding)
  }

  // MARK: Private

  @Binding private var selectedAmenities: Set<RoomAmenity>

  private let onSelect: () -> Void

  private func toggleAmenity(_ amenity: RoomAmenity) {
    if selectedAmenities.contains(amenity) {
      selectedAmenities.remove(amenity)
    } else {
      selectedAmenities.insert(amenity)
    }
  }
}

// MARK: - AmenityButton

private struct AmenityButton: View {

  // MARK: Internal

  let amenity: RoomAmenity
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(amenity.displayName)
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
  AmenityFilterView(selectedAmenities: .constant([.writingBoard]), onSelect: { })
    .defaultTheme()
}
