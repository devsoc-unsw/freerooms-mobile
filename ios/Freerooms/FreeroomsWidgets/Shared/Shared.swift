//
//  Shared.swift
//  Freerooms
//
//  Created by Matthew Yuen on 19/9/2026.
//

import CommonUI
import RoomViews
import SwiftUI
import UIKit
import WidgetKit

// MARK: - Shared

enum Shared {

  static func makeFallback(for family: WidgetFamily) -> Image {
    let size = Configuration.backgroundImageSize(for: family)
    let uiImage = UIImage(named: "default", in: .roomViews, with: nil)!.preparingThumbnail(of: size)!
    return Image(uiImage: uiImage)
  }

}

#warning("TODO: Generate thumbnails manually by clipping the image")

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
