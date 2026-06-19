//
//  TabItems.swift
//  CommonUI
//
//  Created by Matthew Yuen on 14/6/2026.
//

import AppIntents

// MARK: - TabItem

/// The current tab selected in the application
public nonisolated enum TabItem: String {
  case buildings = "Buildings"
  case map = "Map"
  case rooms = "Rooms"
}

// MARK: AppEnum

nonisolated extension TabItem: AppEnum {

  public static let typeDisplayRepresentation: TypeDisplayRepresentation = "Freerooms Tab"

  public static let caseDisplayRepresentations: [TabItem: DisplayRepresentation] = [
    .buildings: "Buildings",
    .map: "Map",
    .rooms: "Rooms",
  ]

}

// MARK: - TabController

@MainActor @Observable
public final class TabController {

  // MARK: Lifecycle

  public init(selectedTab: TabItem = .buildings) {
    self.selectedTab = selectedTab
  }

  // MARK: Public

  public var selectedTab: TabItem
}
