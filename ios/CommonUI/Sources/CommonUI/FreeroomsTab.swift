//
//  FreeroomsTab.swift
//  CommonUI
//
//  Created by Matthew Yuen on 28/8/2026.
//

import AppIntents

public nonisolated enum FreeroomsTab: String, CaseIterable {
  case buildings = "Buildings"
  case map = "Map"
  case rooms = "Rooms"
  case bookings = "Bookings"
}

nonisolated extension FreeroomsTab: AppEnum {
  
  static public let typeDisplayRepresentation: TypeDisplayRepresentation = "Freerooms Tab"
  
  static public let caseDisplayRepresentations: [FreeroomsTab : DisplayRepresentation] = [
    .buildings: DisplayRepresentation(title: "Buildings"),
    .map: DisplayRepresentation(title: "Map"),
    .rooms: DisplayRepresentation(title: "Rooms"),
    .bookings: DisplayRepresentation(title: "Bookings"),
  ]
  
}

@Observable @MainActor
public final class TabController {
  public var currentTab: FreeroomsTab
  
  public init(initialTab: FreeroomsTab = .buildings) {
    self.currentTab = initialTab
  }
  
}
