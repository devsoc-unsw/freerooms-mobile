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

  public static func registerFont(named name: String) {
    guard
      let asset = NSDataAsset(name: "Fonts/\(name)", bundle: Bundle.module),
      let provider = CGDataProvider(data: asset.data as NSData),
      let font = CGFont(provider),
      CTFontManagerRegisterGraphicsFont(font, nil)
    else {
      fatalError("Could not register font file.")
    }
  }
}

extension String {
  public static var ttCommonsPro: Self {
    "TT Commons Pro Trial Variable"
  }
}
