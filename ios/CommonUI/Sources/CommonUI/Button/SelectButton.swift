//
//  SelectButton.swift
//  CommonUI
//
//  Created by Yanlin Li  on 21/11/2025.
//

import SwiftUI

public struct SelectButton: View {

  // MARK: Lifecycle

  public init(onSelect: @escaping () -> Void) {
    self.onSelect = onSelect
  }

  // MARK: Public

  public var body: some View {
    Button {
      onSelect()
    } label: {
      Text("Select")
        .font(.headline)
        .frame(maxWidth: .infinity)
        .frame(height: Self.buttonHeight)
    }
    .buttonStyle(.borderedProminent)
    .tint(theme.accent.primary)
    .buttonBorderShape(.roundedRectangle(radius: Self.cornerRadius))
  }

  // MARK: Internal

  let onSelect: () -> Void

  // MARK: Private

  private static let buttonHeight: CGFloat = 35
  private static let cornerRadius: CGFloat = 20

  @Environment(Theme.self) private var theme
}

#Preview {
  SelectButton { }
    .defaultTheme()
}
