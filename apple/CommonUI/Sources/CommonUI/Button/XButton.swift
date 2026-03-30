//
//  XButton.swift
//  CommonUI
//
//  Created by Dicko Evaldo on 10/10/2025.
//
import SwiftUI

public struct XButton: View {
  public init(action: @escaping () -> Void) {
    self.action = action
  }

  let action: () -> Void

  public var body: some View {
    Button(action: action) {
      ZStack {
        Circle()
          .fill(Color.gray.opacity(0.2))
          .frame(width: 42, height: 42)
        Image(systemName: "xmark")
          .font(.system(size: 20, weight: .medium))
          .foregroundStyle(Color.black)
      }
    }
  }
}
