//
//  CampusLocationFilterView.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 13/10/2025.
//

import RoomModels
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
    VStack(spacing: 20) {
      // Title
      Text("Campus Location")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)

      // Campus location options
      VStack(spacing: 12) {
        ForEach(CampusLocation.allCases) { location in
          CampusLocationButton(
            location: location,
            isSelected: selectedCampusLocation == location)
          {
            selectCampusLocation(location)
          }
        }
      }

      SelectButton(onSelect: onSelect)
    }
    .padding(.horizontal, 20)
    .cornerRadius(20, corners: [.topLeft, .topRight])
  }

  // MARK: Private

  @Binding private var selectedCampusLocation: CampusLocation?

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
        .frame(height: 44)
        .background(isSelected ? theme.accent.primary.opacity(0.1) : Color.gray.opacity(0.1))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 1))
        .cornerRadius(8)
    }
    .buttonStyle(PlainButtonStyle())
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
}

// MARK: - Preview

#Preview {
  CampusLocationFilterView(
    selectedCampusLocation: .constant(.lower))
  {
    // onSelect action
  }
  .defaultTheme()
}
