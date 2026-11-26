//
//  OpenTabIntent.swift
//  FreeroomsIntents
//
//  Created by Matthew Yuen on 28/8/2026.
//

#if hasAttribute(diagnose)
@diagnose(UnusedImportAccess, as: ignored)
#endif
public import AppIntents
public import FreeroomsNavigation

@freestanding(declaration, names: arbitrary)
macro createOpenTabIntent(for tab: FreeroomsTab) = #externalMacro(
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
