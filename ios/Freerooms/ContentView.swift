//
//  ContentView.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import CommonUI
import SwiftUI

struct ContentView: View {
  @Environment(Theme.self) private var theme

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
        .foregroundStyle(theme.accent.primary)
    }
    .padding()
  }
}

#Preview {
  ContentView()
    .defaultTheme()
}
