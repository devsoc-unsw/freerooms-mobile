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

  // MARK: Lifecycle

  init() {
    Theme.registerFont(named: .ttCommonsPro)
    setFontOnToolbars(.ttCommonsPro)
  }

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      ContentView()
        .preferredColorScheme(.light)
        .environment(theme)
        .environment(\.font, Font.custom(.ttCommonsPro, size: 14))
    }
  }

  // MARK: Private

  @State private var theme = Theme.light

}
