//
//  BuildingAnnotationView 2.swift
//  Freerooms
//
//  Created by Dicko Evaldo on 8/8/2025.
//

import BuildingModels
import SwiftUICore

struct BuildingAnnotationView: View {
  let building: Building
  let isSelected: Bool

  var body: some View {
    Circle()
      .fill(building.availabilityColor)
      .frame(
        width: isSelected ? 24 : 16, // ← Bigger when selected
        height: isSelected ? 24 : 16)
      .overlay {
        Circle()
          .stroke(Color.white, lineWidth: isSelected ? 4 : 3) // ← Thicker border when selected
      }
      .shadow(
        color: .black.opacity(0.3),
        radius: isSelected ? 4 : 2, // ← More shadow when selected
        x: 0,
        y: 1)
      .scaleEffect(isSelected ? 1.2 : 1.0) // ← Scale effect for selection
      .animation(.spring(duration: 0.3), value: isSelected) // ← Smooth animation
  }
}
