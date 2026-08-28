//
//  FreeroomsTab.swift
//  CommonUI
//
//  Created by Matthew Yuen on 28/8/2026.
//

import AppIntents

public nonisolated enum FreeroomsTab: String {
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
