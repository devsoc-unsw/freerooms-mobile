//
//  RoomTypeFilterView.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 13/10/2025.
//

import RoomModels
import SwiftUI

// MARK: - RoomTypeFilterView

public struct RoomTypeFilterView: View {

  // MARK: Lifecycle

  public init(
    selectedRoomTypes: Binding<Set<RoomType>>,
    onSelect: @escaping () -> Void)
  {
    _selectedRoomTypes = selectedRoomTypes
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: 0) {
      // Drag handle
      RoundedRectangle(cornerRadius: 2)
        .fill(Color.gray.opacity(0.3))
        .frame(width: 36, height: 4)
        .padding(.top, 8)
        .padding(.bottom, 16)

      // Title
      Text("Room Types")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)

      // Room type grid
      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
        ForEach(RoomType.allCases) { roomType in
          RoomTypeButton(
            roomType: roomType,
            isSelected: selectedRoomTypes.contains(roomType))
          {
            toggleRoomType(roomType)
          }
        }
      }
      .padding(.horizontal, 20)

      // Spacing
      Spacer()
        .frame(height: 20)

      // Select button
      Button(action: onSelect) {
        Text("Select")
          .font(.headline)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Color.orange)
          .cornerRadius(12)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 20)
    }
    .background(Color.white)
    .cornerRadius(20, corners: [.topLeft, .topRight])
  }

  // MARK: Private

  @Binding private var selectedRoomTypes: Set<RoomType>

  private let onSelect: () -> Void

  private func toggleRoomType(_ roomType: RoomType) {
    if selectedRoomTypes.contains(roomType) {
      selectedRoomTypes.remove(roomType)
    } else {
      selectedRoomTypes.insert(roomType)
    }
  }
}

// MARK: - RoomTypeButton

private struct RoomTypeButton: View {
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
        .frame(height: 44)
        .background(isSelected ? Color.white : Color.gray.opacity(0.1))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(isSelected ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 1))
        .cornerRadius(8)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

// MARK: - Preview

#Preview {
  RoomTypeFilterView(
    selectedRoomTypes: .constant([.computerLab]))
  {
    // onSelect action
  }
}
