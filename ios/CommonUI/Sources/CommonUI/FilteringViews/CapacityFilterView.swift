//
//  CapacityFilterView.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 13/10/2025.
//

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

        HStack {
          TextField("Enter capacity", value: $selectedCapacity, format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)

          Text("people")
            .font(.body)
            .foregroundColor(.secondary)
        }
      }

      // Select button
      SelectButton(onSelect: onSelect)
    }
    .padding(.horizontal, 20)
//    .onChange(of: capacityText) { _, newValue in
//      selectedCapacity = newValue
//    }
  }

  // MARK: Private

  @Binding private var selectedCapacity: Int?
  @State private var capacityText: Int? = nil

  private let onSelect: () -> Void

}

// MARK: - Preview

#Preview {
  CapacityFilterView(
    selectedCapacity: .constant(50))
  {
    // onSelect action
  }
  .defaultTheme()
}
