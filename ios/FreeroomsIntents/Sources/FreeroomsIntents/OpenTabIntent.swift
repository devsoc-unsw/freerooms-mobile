//
//  OpenTabIntent.swift
//  FreeroomsIntents
//
//  Created by Matthew Yuen on 28/8/2026.
//

import AppIntents
import CommonUI

@freestanding(declaration, names: arbitrary)
package macro createOpenTabIntent(for tab: FreeroomsTab) = #externalMacro(
  module: "FreeroomsIntentsMacros",
  type: "OpenTabIntentMacro")

// MARK: - TabIntents

public enum TabIntents {
  #createOpenTabIntent(for: .buildings)
  #createOpenTabIntent(for: .map)
  #createOpenTabIntent(for: .rooms)
  #createOpenTabIntent(for: .bookings)
}
