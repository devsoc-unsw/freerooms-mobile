//
//  FreeroomsApp.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import CommonUI
import SwiftUI

@main
struct FreeroomsApp: App {
  @State private var theme = Theme.light

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(theme)
    }
  }
}
