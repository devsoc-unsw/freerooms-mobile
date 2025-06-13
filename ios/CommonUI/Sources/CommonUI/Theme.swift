//
//  Theme.swift
//  CommonUI
//
//  Created by Anh Nguyen on 13/6/2025.
//

import Observation
import SwiftUI

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

}
