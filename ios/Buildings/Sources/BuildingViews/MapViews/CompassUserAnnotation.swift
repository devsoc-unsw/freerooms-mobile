//
//  CompassUserAnnotation.swift
//  Buildings
//
//  Created by Dicko Evaldo on 27/9/2025.
//

import BuildingViewModels
import CoreLocation
import SwiftUI

// MARK: - CompassUserAnnotation

struct CompassUserAnnotation: View {

  // MARK: Internal

  var body: some View {
    ZStack {
      // Pulsing outer ring
      Circle()
        .stroke(.blue.opacity(0.3), lineWidth: 2)
        .frame(width: isPulsing ? 40 : 20, height: isPulsing ? 40 : 20)
        .opacity(isPulsing ? 0 : 1)

      // Main user circle
      Circle()
        .fill(.blue)
        .frame(width: 16, height: 16)
        .overlay(
          Circle()
            .stroke(.white, lineWidth: 2))

      // Heading indicator (arrow/cone)
      DirectionalArrow()
        .fill(.blue)
        .frame(width: 8, height: 12)
        .offset(y: -14)
        .rotationEffect(.degrees(viewModel.mapHeading))
        .rotationEffect(.degrees(headingValue))
        .shadow(color: .white, radius: 1)
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
        isPulsing = true
      }
    }
  }

  // MARK: Private

  @Environment(LiveMapViewModel.self) private var viewModel

  @State private var isPulsing = false

  private var headingValue: Double {
    viewModel.userHeading.trueHeading >= 0 ? viewModel.userHeading.trueHeading : viewModel.userHeading.magneticHeading
  }

}

// MARK: - DirectionalArrow

struct DirectionalArrow: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()

    // Create arrow pointing up
    path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // Tip
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.7)) // Left wing
    path.addLine(to: CGPoint(x: rect.midX * 0.8, y: rect.maxY * 0.7)) // Left inner
    path.addLine(to: CGPoint(x: rect.midX * 0.8, y: rect.maxY)) // Left shaft
    path.addLine(to: CGPoint(x: rect.midX * 1.2, y: rect.maxY)) // Right shaft
    path.addLine(to: CGPoint(x: rect.midX * 1.2, y: rect.maxY * 0.7)) // Right inner
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.7)) // Right wing
    path.closeSubpath()

    return path
  }
}
