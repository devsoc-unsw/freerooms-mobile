//
//  FreeroomsWidgetIntentsPackage.swift
//  FreeroomsIntents
//
//  Created by Matthew Yuen on 11/9/2026.
//

public import AppIntents
import FreeroomsEntities

public struct FreeroomsWidgetIntentsPackage: AppIntentsPackage {
  static public var includedPackages: [any AppIntentsPackage.Type] {
    [FreeroomsEntitiesPackage.self]
  }
}
