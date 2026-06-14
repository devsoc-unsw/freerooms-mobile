//
//  TabItems.swift
//  CommonUI
//
//  Created by Matthew Yuen on 14/6/2026.
//

import AppIntents

/// The current tab selected in the application
public nonisolated enum TabItem: String {
  case buildings  = "Buildings"
  case map        = "Map"
  case rooms      = "Rooms"
}

nonisolated extension TabItem: AppEnum {
  
  public static var typeDisplayRepresentation: TypeDisplayRepresentation {
    "Freerooms Tab"
  }
  
  public static var caseDisplayRepresentations: [TabItem : DisplayRepresentation] {
    [
      .buildings: "Buildings",
      .map:       "Map",
      .rooms:     "Rooms",
    ]
  }
  
}
