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
          .fill(Color.gray.opacity(Self.backgroundOpacity))
          .frame(width: Self.buttonSize, height: Self.buttonSize)
        Image(systemName: "xmark")
          .font(.system(size: Self.iconSize, weight: .medium))
          .foregroundStyle(Color.black)
      }
    }
  }

  // MARK: Internal

  let action: () -> Void

  // MARK: Private

  private static let backgroundOpacity = 0.2
  private static let buttonSize: CGFloat = 42
  private static let iconSize: CGFloat = 20
}
