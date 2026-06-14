//
//  Untitled.swift
//  Freerooms
//
//  Created by Matthew Yuen on 14/6/2026.
//

import AppIntents

/// An intent that opens a specific tab
struct OpenTabIntent: AppIntent {
  
  static var title: LocalizedStringResource {
    "Open Tab"
  }
  
  static var openAppWhenRun: Bool {
    true
  }
  
  @available(iOS 26.0, macOS 26.0, macCatalyst 26.0, watchOS 26.0, tvOS 26.0, *)
  static var supportedModes: IntentModes {
    .foreground
  }
  
  func perform() async throws -> some IntentResult {
    return .result()
  }
  
  @Dependency
  private var tabController: TabController
  
}
