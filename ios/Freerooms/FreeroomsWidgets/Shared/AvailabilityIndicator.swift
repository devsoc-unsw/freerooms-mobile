//
//  AvailabilityIndicator.swift
//  Freerooms
//
//  Created by Matthew Yuen on 19/9/2026.
//

import SwiftUI

struct AvailabilityIndicator: View {

  // MARK: Lifecycle

  init(availableRooms: Int?) {
    guard let availableRooms else {
      self.indicatorColor = .gray
      return
    }
    self.indicatorColor = switch availableRooms {
    case 5...: .green
    case 1..<5: .yellow
    case 0: .red
    default:
      .gray
    }
  }
  
  init(isAvailable: Bool?) {
    guard let isAvailable else {
      self.indicatorColor = .gray
      return
    }
    self.indicatorColor = isAvailable ? .green : .red
  }

  // MARK: Internal
  
  let indicatorColor: Color

  var body: some View {
    let width: CGFloat = 8

    Circle()
      .foregroundStyle(indicatorColor)
      .frame(width: width, height: width)
      .shadow(color: indicatorColor.opacity(0.5), radius: 5)
  }
}
