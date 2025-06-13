//
//  Theme.swift
//  CommonUI
//
//  Created by Anh Nguyen on 13/6/2025.
//

import CoreGraphics
import CoreText
import Observation
import SwiftUI
import UIKit

// MARK: - Theme

@Observable
@MainActor
public final class Theme {

  // MARK: Lifecycle

  public init(accent: Accent) {
    self.accent = accent
  }

  // MARK: Public

  public struct Accent {
    public let primary: Color
    public let secondary: Color

    public init(primary: Color, secondary: Color) {
      self.primary = primary
      self.secondary = secondary
    }
  }

  public static let light = Theme(accent: .init(
    primary: Color("AccentPrimary", bundle: .module),
    secondary: Color("AccentSecondary", bundle: .module)))

  public var accent: Accent

  /// DO NOT CALL IN PREVIEWS
  public static func registerFont(named name: String) {
    guard let asset = NSDataAsset(name: "Fonts/\(name)", bundle: Bundle.module) else {
      fatalError("Could not find font asset.")
    }
    guard let provider = CGDataProvider(data: asset.data as NSData) else {
      fatalError("Could not create data provider for font file.")
    }
    guard let font = CGFont(provider) else {
      fatalError("Could not create CGFont.")
    }
    guard CTFontManagerRegisterGraphicsFont(font, nil) else {
      fatalError("Could not set font.")
    }
  }
}

extension String {
  public static var ttCommonsPro: Self {
    "TT Commons Pro Trial Variable"
  }
}

// MARK: - DefaultTheme

struct DefaultTheme: ViewModifier {
  func body(content: Content) -> some View {
    content
      .environment(Theme.light)
      .environment(\.font, Font.custom(.ttCommonsPro, size: 14))
  }
}

extension View {
  /// Adds default theming for previews.
  public func defaultTheme() -> some View {
    modifier(DefaultTheme())
  }
}
