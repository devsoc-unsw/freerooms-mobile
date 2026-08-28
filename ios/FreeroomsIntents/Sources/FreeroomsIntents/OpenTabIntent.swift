//
//  OpenTabIntent.swift
//  FreeroomsIntents
//
//  Created by Matthew Yuen on 28/8/2026.
//

public import AppIntents
public import CommonUI

public struct OpenTabIntent: AppIntent {
  public static let title: LocalizedStringResource = "Open Tab"
  public static let description = IntentDescription("Opens a tab")
  
  @Dependency
  public var tabController: TabController
  
  @Parameter(title: "Tab")
  public var tab: FreeroomsTab
  
  public init() {}
  
  public init(tab: FreeroomsTab) {
    self.tab = tab
  }
  
  @MainActor
  public func perform() async throws -> some IntentResult {
    tabController.currentTab = tab
    return .result()
  }
  
}
