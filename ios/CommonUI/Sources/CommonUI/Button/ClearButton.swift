//
//  SwiftUIView.swift
//  CommonUI
//
//  Created by Yanlin Li  on 4/4/2026.
//

import SwiftUI

public struct ClearButton: View {

  // MARK: Lifecycle

  public init(filterName: String, clearFilter: @escaping () -> Void, onSelect: @escaping () -> Void) {
    self.filterName = filterName
    self.clearFilter = clearFilter
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    Button(role: .destructive) {
      clearFilter()
      onSelect()
    } label: {
      Text("Clear \(filterName)")
        .font(.body)
        .fontWeight(.medium)
        .frame(maxWidth: .infinity)
        .frame(height: Self.buttonHeight)
    }
    .buttonStyle(.bordered)
    .tint(.red)
    .buttonBorderShape(.roundedRectangle(radius: Self.cornerRadius))
  }

  // MARK: Internal

  let clearFilter: () -> Void
  let onSelect: () -> Void
  let filterName: String

  // MARK: Private

  private static let buttonHeight: CGFloat = 35
  private static let cornerRadius: CGFloat = 20
}

#Preview {
  ClearButton(filterName: "Duration", clearFilter: { }, onSelect: { })
    .defaultTheme()
}
