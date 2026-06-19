//
//  OpenAppTabIndent.swift
//  Freerooms
//
//  Created by Matthew Yuen on 14/6/2026.
//

import AppIntents
import CommonUI

// TODO: See if we can paramaterize an open widget with the required type,
// instead of copying the same intent over and over.

// MARK: - OpenBuildingsTabIntent

struct OpenBuildingsTabIntent: AppIntent {

  // MARK: Internal

  static var title: LocalizedStringResource {
    "Open Buildings"
  }

  static var openAppWhenRun: Bool {
    true
  }

  @available(iOS 26.0, macOS 26.0, macCatalyst 26.0, watchOS 26.0, tvOS 26.0, *)
  static var supportedModes: IntentModes {
    .foreground(.immediate)
  }

  @MainActor
  func perform() async throws -> some IntentResult {
    tabController.selectedTab = .buildings
    return .result()
  }

  // MARK: Private

  @Dependency private var tabController: TabController

}

// MARK: - OpenMapTabIntent

struct OpenMapTabIntent: AppIntent {

  // MARK: Internal

  static var title: LocalizedStringResource {
    "Open Map"
  }

  static var openAppWhenRun: Bool {
    true
  }

  @available(iOS 26.0, macOS 26.0, macCatalyst 26.0, watchOS 26.0, tvOS 26.0, *)
  static var supportedModes: IntentModes {
    .foreground(.immediate)
  }

  @MainActor
  func perform() async throws -> some IntentResult {
    tabController.selectedTab = .map
    return .result()
  }

  // MARK: Private

  @Dependency private var tabController: TabController

}

// MARK: - OpenRoomsTabIntent

struct OpenRoomsTabIntent: AppIntent {

  // MARK: Internal

  static var title: LocalizedStringResource {
    "Open Rooms"
  }

  static var openAppWhenRun: Bool {
    true
  }

  @available(iOS 26.0, macOS 26.0, macCatalyst 26.0, watchOS 26.0, tvOS 26.0, *)
  static var supportedModes: IntentModes {
    .foreground(.immediate)
  }

  @MainActor
  func perform() async throws -> some IntentResult {
    tabController.selectedTab = .rooms
    return .result()
  }

  // MARK: Private

  @Dependency private var tabController: TabController

}
