//
//  FilterSheetLayout.swift
//  CommonUI
//

import SwiftUI

public enum FilterSheetLayout {
  /// Inset below the sheet grabber so titles are not clipped by the top corner radius.
  public static let contentTopPadding: CGFloat = 44

  /// Inset above the sheet bottom corner radius/border so bottom content isn't clipped/overlapped.
  public static let contentBottomPadding: CGFloat = 24
}
