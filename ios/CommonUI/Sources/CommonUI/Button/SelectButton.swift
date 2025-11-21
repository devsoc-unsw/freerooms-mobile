//
//  SelectButton.swift
//  CommonUI
//
//  Created by Yanlin Li  on 21/11/2025.
//

import SwiftUI

public struct SelectButton: View {
  
  public init(onSelect: @escaping () -> Void) {
    self.onSelect = onSelect
  }
    public var body: some View {
      Button(action: onSelect) {
        Text("Select")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(theme.accent.primary)
          .cornerRadius(12)
      }
    }
  
  let onSelect: () -> Void
  @Environment(Theme.self) private var theme
}

#Preview {
  SelectButton() {}
    .defaultTheme()
}
