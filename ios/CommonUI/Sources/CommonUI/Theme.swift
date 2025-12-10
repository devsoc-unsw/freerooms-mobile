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

@MainActor
@Observable
public final class Theme {

  // MARK: Lifecycle

  public init(accent: Accent, label: Label, background: Color, toolbar: Color, yellow: Color, white: Color, list: ListColors) {
    self.accent = accent
    self.label = label
    self.background = background
    self.toolbar = toolbar
    self.yellow = yellow
    self.white = white
    self.list = list
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

  public struct ListColors {
    public let red: Color
    public let redBackground: Color
    public let green: Color
    public let greenBackground: Color
    public let gray: Color
    public let grayBackground: Color
    public let yellow: Color
    public let yellowBackground: Color

    public init(red: Color, redBackground: Color, green: Color, greenBackground: Color, gray: Color, grayBackground: Color, yellow: Color, yellowBackground: Color) {
      self.red = red
      self.redBackground = redBackground
      self.green = green
      self.greenBackground = greenBackground
      self.gray = gray
      self.grayBackground = grayBackground
      self.yellow = yellow
      self.yellowBackground = yellowBackground
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
    white: .init("White", bundle: .module),
    list: .init(
      red: Color("Red", bundle: .module),
      redBackground: Color("RedBackground", bundle: .module),
      green: Color("Green", bundle: .module),
      greenBackground: Color("GreenBackground", bundle: .module),
      gray: Color("Gray", bundle: .module),
      grayBackground: Color("GrayBackground", bundle: .module),
      yellow: Color("Yellow", bundle: .module),
      yellowBackground: Color("YellowBackground", bundle: .module)),
  )

  public var accent: Accent
  public var label: Label
  public var background: Color
  public var toolbar: Color
  public var yellow: Color
  public var white: Color
  public var list: ListColors

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

/// This cannot be called directly in preview, but you may call it in a view initialiser if it is required for correct preview
@MainActor
public func setFontOnToolbars(_ font: String) {
  setFontOnNavigationBarLargeTitle(font)
  setFontOnNavigationBarTitle(font)
  setFontOnTabBar(font)
}

@MainActor
func setFontOnNavigationBarLargeTitle(_ font: String) {
  let largeTitlePointSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
  var largeTitleFont = UIFont(name: font, size: largeTitlePointSize)
  if let largeTitleBoldFontDescriptor = largeTitleFont?.fontDescriptor.withSymbolicTraits(.traitBold) {
    largeTitleFont = UIFont(descriptor: largeTitleBoldFontDescriptor, size: largeTitlePointSize) // Make it bold
  }
  let largeTitleTextAttributes = [
    NSAttributedString.Key.font: largeTitleFont as Any,
    NSAttributedString.Key.foregroundColor: UIColor(Theme.light.label.primary),
  ]
  UINavigationBar.appearance().largeTitleTextAttributes = largeTitleTextAttributes
}

@MainActor
func setFontOnNavigationBarTitle(_ font: String) {
  let titlePointSize = UIFont.preferredFont(forTextStyle: .body).pointSize
  var titleFont = UIFont(name: font, size: titlePointSize)
  if let titleBoldFontDescriptor = titleFont?.fontDescriptor.withSymbolicTraits(.traitBold) {
    titleFont = UIFont(descriptor: titleBoldFontDescriptor, size: titlePointSize) // Make it bold
  }
  let titleTextAttributes = [
    NSAttributedString.Key.font: titleFont as Any,
    NSAttributedString.Key.foregroundColor: UIColor(Theme.light.label.primary),
  ]
  UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
}

@MainActor
func setFontOnTabBar(_ font: String) {
  UITabBarItem.appearance().setTitleTextAttributes(
    [.font: UIFont(name: font, size: UIFont.preferredFont(forTextStyle: .caption2).pointSize) as Any],
    for: .normal)
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
