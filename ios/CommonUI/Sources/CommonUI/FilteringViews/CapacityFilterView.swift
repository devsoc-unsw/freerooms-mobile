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
    VStack(spacing: 0) {
      // Title
      Text("Capacity")
        .font(.title2)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)

      // Capacity input
      VStack(alignment: .leading, spacing: 16) {
        Text("Minimum capacity")
          .font(.body)
          .foregroundColor(.secondary)

        HStack {
          TextField("Enter capacity", value: $capacityText, format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)

          Text("people")
            .font(.body)
            .foregroundColor(.secondary)
        }
      }
      .padding(.horizontal, 20)

      Spacer()

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
    .onChange(of: capacityText) { _, newValue in
      selectedCapacity = newValue
    }
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
}
