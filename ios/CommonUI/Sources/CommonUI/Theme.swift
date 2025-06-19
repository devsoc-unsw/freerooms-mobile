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

  public init(accent: Accent, label: Label, background: Color, toolbar: Color, yellow: Color, white: Color) {
    self.accent = accent
    self.label = label
    self.background = background
    self.toolbar = toolbar
    self.yellow = yellow
    self.white = white
  }

  // MARK: Public

  public struct Accent {
    public let primary: Color
    public let secondary: Color
    public let tertiary: Color
    public let quaternary: Color

    public init(primary: Color, secondary: Color, tertiary: Color, quaternary: Color) {
      self.primary = primary
      self.secondary = secondary
      self.tertiary = tertiary
      self.quaternary = quaternary
    }
  }

  public struct Label {
    public let primary: Color
    public let secondary: Color
    public let tertiary: Color

    public init(primary: Color, secondary: Color, tertiary: Color) {
      self.primary = primary
      self.secondary = secondary
      self.tertiary = tertiary
    }
  }

  public static let light = Theme(
    accent: .init(
      primary: Color("AccentPrimary", bundle: .module),
      secondary: Color("AccentSecondary", bundle: .module),
      tertiary: Color("AccentTertiary", bundle: .module),
      quaternary: Color("AccentQuarternary", bundle: .module)),
    label: .init(
      primary: Color("LabelPrimary", bundle: .module),
      secondary: Color("LabelSecondary", bundle: .module),
      tertiary: Color("LabelTertiary", bundle: .module)),
    background: .init("Background", bundle: .module),
    toolbar: .init("Toolbar", bundle: .module),
    yellow: .init("Yellow", bundle: .module),
    white: .init("White", bundle: .module))

  public var accent: Accent
  public var label: Label
  public var background: Color
  public var toolbar: Color
  public var yellow: Color
  public var white: Color

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
