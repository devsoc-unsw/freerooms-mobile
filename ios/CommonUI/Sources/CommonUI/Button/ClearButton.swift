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
        .frame(height: 35)
    }
    .buttonStyle(.bordered)
    .tint(.red)
    .buttonBorderShape(.roundedRectangle(radius: 20))
  }

  // MARK: Internal

  let clearFilter: () -> Void
  let onSelect: () -> Void
  let filterName: String
}

#Preview {
  ClearButton(filterName: "Duration", clearFilter: { }, onSelect: { })
    .defaultTheme()
}
