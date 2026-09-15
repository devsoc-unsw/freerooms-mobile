//
//  FreeroomsWidgetsBundle.swift
//  FreeroomsWidgets
//
//  Created by Matthew Yuen on 28/8/2026.
//

import AppIntents
import FreeroomsEntities
import FreeroomsWidgetIntents
import SwiftUI
import WidgetKit

// MARK: - FreeroomsWidgetsBundle

@main
struct FreeroomsWidgetsBundle: WidgetBundle {
  var body: some Widget {
    OpenTabWidget()
    BuildingWidget()
  }
}
