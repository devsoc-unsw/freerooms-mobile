//
//  BuildingAnnotationView 2.swift
//  Freerooms
//
//  Created by Dicko Evaldo on 8/8/2025.
//

import BuildingModels
import SwiftUI

struct BuildingAnnotationView: View {
  let building: Building
  let isSelected: Bool

  var body: some View {
    Circle()
      .fill(building.availabilityColor)
      .frame(
        width: isSelected ? MapLayoutConstants.selectedAnnotationSize : MapLayoutConstants.defaultAnnotationSize,
        height: isSelected ? MapLayoutConstants.selectedAnnotationSize : MapLayoutConstants.defaultAnnotationSize)
      .overlay {
        Circle()
          .stroke(
            Color.white,
            lineWidth: isSelected
              ? MapLayoutConstants.selectedAnnotationBorderWidth
              : MapLayoutConstants.defaultAnnotationBorderWidth)
      }
      .shadow(
        color: .black.opacity(MapLayoutConstants.annotationShadowOpacity),
        radius: isSelected
          ? MapLayoutConstants.selectedAnnotationShadowRadius
          : MapLayoutConstants.unselectedAnnotationShadowRadius,
        x: MapLayoutConstants.sheetShadowXOffset,
        y: MapLayoutConstants.annotationShadowYOffset)
      .scaleEffect(isSelected ? MapLayoutConstants.annotationScaleWhenSelected : MapLayoutConstants.unselectedAnnotationScale)
      .animation(.spring(duration: MapLayoutConstants.annotationSelectionAnimationDuration), value: isSelected)
      .contentShape(Rectangle())
      .frame(width: MapLayoutConstants.annotationHitTargetWidth)
  }
}
