//
//  OpenTabIntent.swift
//  FreeroomsIntents
//
//  Created by Matthew Yuen on 28/8/2026.
//

import AppIntents
import CommonUI

@freestanding(declaration, names: arbitrary)
internal macro createOpenTabIntent(for tab: FreeroomsTab) = #externalMacro(
  module: "FreeroomsIntentsMacros",
  type: "OpenTabIntentMacro")

// MARK: - TabIntents

/// A `namespace` for the open tab intents
///
/// This is necessary, as macros that generate arbitrary names at the global scope is not allowed.
/// - Macros are used, as widget intents do not support static parameters being passed
public enum TabIntents {
  #createOpenTabIntent(for: .buildings)
  #createOpenTabIntent(for: .map)
  #createOpenTabIntent(for: .rooms)
  #createOpenTabIntent(for: .bookings)
}
