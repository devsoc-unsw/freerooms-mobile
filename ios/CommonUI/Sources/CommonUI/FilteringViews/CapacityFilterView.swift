//
//  CapacityFilterView.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 13/10/2025.
//

import RoomViewModels
import SwiftUI

// MARK: - CapacityFilterView

public struct CapacityFilterView: View {

  // MARK: Lifecycle

  public init(
    selectedCapacity: Binding<Int?>,
    onSelect: @escaping () -> Void)
  {
    _selectedCapacity = selectedCapacity
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: 30) {
      // Title
      Text("Capacity")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      // Capacity input
      VStack(alignment: .leading, spacing: 16) {
        Text("Minimum capacity")
          .font(.body)
          .foregroundColor(.secondary)

        // Quick picks so users don't need to type a value.
        LazyVGrid(
          columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
          spacing: 12
        ) {
          ForEach(Self.quickCapacityOptions, id: \.self) { option in
            capacityPresetButton(for: option)
          }
        }

        HStack {
          TextField("Enter capacity", value: $selectedCapacity, format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)

          Text("people")
            .font(.body)
            .foregroundColor(.secondary)
        }
      }

      Button(role: .cancel, action: {
        roomViewModel.clearCapacityFilter()
        onSelect()
      }) {
        Text("Clear minimum capacity")
          .font(.body)
          .fontWeight(.medium)
          .frame(maxWidth: .infinity)
          .frame(height: 44)
      }

      // Select button
      SelectButton(onSelect: onSelect)
    }
    .padding(.horizontal, 20)
    .padding(.top, FilterSheetLayout.contentTopPadding)
    .padding(.bottom, FilterSheetLayout.contentBottomPadding)
//    .onChange(of: capacityText) { _, newValue in
//      selectedCapacity = newValue
//    }
  }

  // MARK: Private

  @Binding private var selectedCapacity: Int?
  @Environment(LiveRoomViewModel.self) private var roomViewModel
  @Environment(Theme.self) private var theme
  private let onSelect: () -> Void

  private static let quickCapacityOptions: [Int] = [10, 25, 50, 100]

  @ViewBuilder
  private func capacityPresetButton(for option: Int) -> some View {
    Button {
      selectedCapacity = option
      onSelect()
    } label: {
      Text("\(option)")
        .font(.body)
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(selectedCapacity == option
          ? theme.accent.primary.opacity(0.25)
          : Color.gray.opacity(0.1))
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(selectedCapacity == option ? theme.accent.primary : Color.clear, lineWidth: 1)
        )
        .cornerRadius(10)
    }
    .buttonStyle(.plain)
  }

}

// MARK: - Preview

#Preview {
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()
  return CapacityFilterView(selectedCapacity: .constant(50), onSelect: { })
    .defaultTheme()
    .environment(viewModel)
}
