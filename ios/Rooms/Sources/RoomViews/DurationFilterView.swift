//
//  DurationFilterView.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 13/10/2025.
//

import RoomModels
import SwiftUI

// MARK: - DurationFilterView

public struct DurationFilterView: View {

  // MARK: Lifecycle

  public init(
    selectedDuration: Binding<Duration?>,
    onSelect: @escaping () -> Void)
  {
    _selectedDuration = selectedDuration
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
      Text("Duration")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)

      // Duration options
      HStack(spacing: 0) {
        ForEach(Duration.allCases) { duration in
          DurationButton(
            duration: duration,
            isSelected: selectedDuration == duration)
          {
            selectDuration(duration)
          }
        }
      }
      .padding(.horizontal, 20)
      .background(Color.gray.opacity(0.1))
      .cornerRadius(8)
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

  @Binding private var selectedDuration: Duration?

  private let onSelect: () -> Void

  private func selectDuration(_ duration: Duration) {
    selectedDuration = duration
  }
}

// MARK: - DurationButton

private struct DurationButton: View {
  let duration: Duration
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(duration.displayName)
        .font(.body)
        .fontWeight(.medium)
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(isSelected ? Color.white : Color.clear)
        .overlay(
          RoundedRectangle(cornerRadius: 6)
            .stroke(Color.clear, lineWidth: 0))
        .cornerRadius(6)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

// MARK: - Preview

#Preview {
  DurationFilterView(
    selectedDuration: .constant(.oneHour))
  {
    // onSelect action
  }
}
