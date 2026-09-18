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
    RoomWidget()
  }
}

// MARK: - Configuration

enum Configuration {

  /// How long we should wait on an error to refresh info
  static let errorRetryInterval: TimeInterval = 5 * 60

  // MARK: Image Sizes

  /// How big to make background images for the `WidgetFamily.systemLarge` size
  static let systemLargeBackgroundImageSize = CGSize(width: 1024, height: 1024)
  /// How big to make background images for the `WidgetFamily.systemMedium` size
  static let systemMediumBackgroundImageSize = CGSize(width: 1024, height: 512)

  /// Additional padding to add around the widget
  static let additionalPadding: CGFloat = 8

  static func backgroundImageSize(for widgetFamily: WidgetFamily) -> CGSize {
    switch widgetFamily {
    case .systemLarge:
      Self.systemLargeBackgroundImageSize
    case .systemMedium:
      Self.systemMediumBackgroundImageSize
    default:
      Self.systemLargeBackgroundImageSize
    }
  }

}
