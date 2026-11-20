//
//  WidgetGradients.swift
//  Freerooms
//
//  Created by Matthew Yuen on 19/9/2026.
//

import CommonUI
import SwiftUI

// MARK: - WidgetGradients

struct WidgetGradients: ViewModifier {
  let theme = Theme.default

  func body(content: Content) -> some View {
    content
      .overlay {
        LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
      }
      .overlay {
        LinearGradient(colors: [theme.accent.primary.opacity(0.1), .clear], startPoint: .topTrailing, endPoint: .bottomLeading)
      }
  }
}

extension View {
  func addWidgetGradients() -> some View {
    modifier(WidgetGradients())
  }
}
