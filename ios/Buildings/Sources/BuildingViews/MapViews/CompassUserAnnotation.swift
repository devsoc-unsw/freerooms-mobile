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
        .stroke(.blue.opacity(Self.pulseRingOpacity), lineWidth: Self.strokeWidth)
        .frame(
          width: isPulsing ? Self.expandedPulseSize : Self.collapsedPulseSize,
          height: isPulsing ? Self.expandedPulseSize : Self.collapsedPulseSize)
        .opacity(isPulsing ? Self.hiddenOpacity : Self.visibleOpacity)

      // Main user circle
      Circle()
        .fill(.blue)
        .frame(width: Self.userDotSize, height: Self.userDotSize)
        .overlay(
          Circle()
            .stroke(.white, lineWidth: Self.strokeWidth))

      // Heading indicator (arrow/cone)
      DirectionalArrow()
        .fill(.blue)
        .frame(width: Self.arrowWidth, height: Self.arrowHeight)
        .offset(y: Self.arrowYOffset)
        .rotationEffect(.degrees(headingValue))
        .rotationEffect(.degrees(-viewModel.mapHeading))
        .shadow(color: .white, radius: Self.arrowShadowRadius)
    }
    .onAppear {
      withAnimation(.easeInOut(duration: Self.pulseAnimationDuration).repeatForever()) {
        isPulsing = true
      }
    }
  }

  // MARK: Private

  private static let arrowHeight: CGFloat = 12
  private static let arrowShadowRadius: CGFloat = 1
  private static let arrowWidth: CGFloat = 8
  private static let arrowYOffset: CGFloat = -14
  private static let collapsedPulseSize: CGFloat = 20
  private static let expandedPulseSize: CGFloat = 40
  private static let hiddenOpacity = 0.0
  private static let pulseAnimationDuration = 1.5
  private static let pulseRingOpacity = 0.3
  private static let strokeWidth: CGFloat = 2
  private static let userDotSize: CGFloat = 16
  private static let visibleOpacity = 1.0

  @Environment(LiveMapViewModel.self) private var viewModel

  @State private var isPulsing = false

  private var headingValue: Double {
    viewModel.userHeading.trueHeading >= 0 ? viewModel.userHeading.trueHeading : viewModel.userHeading.magneticHeading
  }

}

// MARK: - DirectionalArrow

struct DirectionalArrow: Shape {

  // MARK: Internal

  func path(in rect: CGRect) -> Path {
    var path = Path()

    // Create arrow pointing up
    path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // Tip
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * Self.wingYRatio)) // Left wing
    path.addLine(to: CGPoint(x: rect.midX * Self.innerXRatio, y: rect.maxY * Self.wingYRatio)) // Left inner
    path.addLine(to: CGPoint(x: rect.midX * Self.innerXRatio, y: rect.maxY)) // Left shaft
    path.addLine(to: CGPoint(x: rect.midX * Self.outerXRatio, y: rect.maxY)) // Right shaft
    path.addLine(to: CGPoint(x: rect.midX * Self.outerXRatio, y: rect.maxY * Self.wingYRatio)) // Right inner
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * Self.wingYRatio)) // Right wing
    path.closeSubpath()

    return path
  }

  // MARK: Private

  /// Shape ratios keep the heading arrow proportional regardless of rendered frame size.
  private static let innerXRatio = 0.8
  private static let outerXRatio = 1.2
  private static let wingYRatio = 0.7
}
