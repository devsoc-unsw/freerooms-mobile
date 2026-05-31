//
//  XButton.swift
//  CommonUI
//
//  Created by Dicko Evaldo on 10/10/2025.
//

import SwiftUI

public struct XButton: View {

  // MARK: Lifecycle

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  // MARK: Public

  public var body: some View {
    Button(action: action) {
      ZStack {
        Circle()
          .fill(Color.gray.opacity(0.2))
          .frame(width: 42, height: 42)
        Image(systemName: "xmark")
          .font(.system(size: 20, weight: .medium))
          .foregroundStyle(theme.black)
      }
    }
  }

  // MARK: Internal

  let action: () -> Void

  // MARK: Private

  @Environment(Theme.self) private var theme
}
