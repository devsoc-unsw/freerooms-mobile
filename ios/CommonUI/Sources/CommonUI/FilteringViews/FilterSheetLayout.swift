//
//  FilterSheetLayout.swift
//  CommonUI
//

import SwiftUI

public enum FilterSheetLayout {
  public static let contentSpacing: CGFloat = 15
  public static let horizontalPadding: CGFloat = 20

  /// Inset below the sheet grabber so titles are not clipped by the top corner radius.
  public static let contentTopPadding: CGFloat = 44

  /// Inset above the sheet bottom corner radius/border so bottom content isn't clipped/overlapped.
  public static let contentBottomPadding: CGFloat = 24

  public static let optionColumnCount = 2
  public static let optionSpacing: CGFloat = 12
  public static let optionHeight: CGFloat = 44
  public static let optionCornerRadius: CGFloat = 8
  public static let optionStrokeWidth: CGFloat = 1
  public static let unselectedOptionBackgroundOpacity = 0.1
}
