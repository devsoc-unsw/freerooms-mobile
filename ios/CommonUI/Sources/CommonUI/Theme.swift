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

  private init() { }

  // MARK: Public

  public struct Accent {
    public let primary = Color("AccentPrimary", bundle: .module)
    public let secondary = Color("AccentSecondary", bundle: .module)
    public let tertiary = Color("AccentTertiary", bundle: .module)
    public let quaternary = Color("AccentQuarternary", bundle: .module)
  }

  public struct Label {
    public let primary = Color("LabelPrimary", bundle: .module)
    public let secondary = Color("LabelSecondary", bundle: .module)
    public let tertiary = Color("LabelTertiary", bundle: .module)
  }

  public struct Background {
    public let primary = Color("BackgroundPrimary", bundle: .module)
    public let secondary = Color("BackgroundSecondary", bundle: .module)
  }

  public struct ListColors {
    public let red = Color("Red", bundle: .module)
    public let redBackground = Color("RedBackground", bundle: .module)
    public let green = Color("Green", bundle: .module)
    public let greenBackground = Color("GreenBackground", bundle: .module)
    public let gray = Color("Gray", bundle: .module)
    public let grayBackground = Color("GrayBackground", bundle: .module)
    public let yellow = Color("Yellow", bundle: .module)
    public let yellowBackground = Color("YellowBackground", bundle: .module)
  }

  /// Colors resolve dynamically from the asset catalog based on the system appearance.
  public static let `default` = Theme()

  public let accent = Accent()
  public let label = Label()
  public let background = Background()
  public let toolbar = Color("Toolbar", bundle: .module)
  public let yellow = Color("Yellow", bundle: .module)
  public let white = Color("White", bundle: .module)
  public let black = Color("Black", bundle: .module)
  public let list = ListColors()

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
    NSAttributedString.Key.foregroundColor: UIColor(Theme.default.label.primary),
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
    NSAttributedString.Key.foregroundColor: UIColor(Theme.default.label.primary),
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
      .environment(Theme.default)
      .environment(\.font, Font.custom(.ttCommonsPro, size: 14))
  }
}

extension View {
  /// Adds default theming for previews.
  public func defaultTheme() -> some View {
    modifier(DefaultTheme())
  }
}
