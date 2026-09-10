//
//  BuildingTimelineProvider.swift
//  Freerooms
//
//  Created by Matthew Yuen on 7/9/2026.
//

import AppIntents
import BuildingModels
import BuildingServices
import BuildingViews
import CommonUI
import FreeroomsIntents
import Networking
import SwiftUI
import WidgetKit

/// How long we should wait on an error to refresh building info
let errorRetryInterval: TimeInterval = 5 * 60

// MARK: - BuildingTimelineProvider

struct BuildingTimelineProvider: AppIntentTimelineProvider {

  // MARK: Lifecycle

  init() {
    buildingLoader = .default
  }

  // MARK: Internal

  struct Entry: TimelineEntry {
    let date = Date()
    let value: Value

    enum Value {
      case building(Building, image: Image?)
      case missingBuilding
      case failed(any Error)
    }
  }

  typealias Intent = BuildingConfigurationIntent

  let buildingLoader: LiveGraphQLBuildingLoader

  func snapshot(for configuration: Intent, in _: Context) async -> Entry {
    guard let selectedBuilding = configuration.building else {
      return .missingBuilding
    }

    do {
      let building = try await buildingLoader.fetch(id: selectedBuilding.id).get()
      return .building(building)
    } catch {
      return .failed(error)
    }
  }

  func timeline(for configuration: Intent, in _: Context) async -> Timeline<Entry> {
    // Check if a building was configured for display
    guard let selectedBuilding = configuration.building else {
      // Return an empty state. Don't refresh until a building is selected
      return .missingBuilding
    }

    do {
      // Load the current building status
      let building = try await buildingLoader.fetch(id: selectedBuilding.id).get()
      return .building(building)
    } catch {
      return .failed(error)
    }
  }

  func placeholder(in _: Context) -> Entry {
    .placeholder
  }

}

extension BuildingTimelineProvider.Entry {
  static var placeholder: Self {
    // Use a random placeholder building
    let previewBuilding = Building(
      name: "Morven Brown Building",
      id: "K-C20",
      latitude: -33.916792,
      longitude: 151.232828,
      aliases: [],
      numberOfAvailableRooms: 15)

    return .building(previewBuilding)
  }

  static var missingBuilding: Self {
    Self(value: .missingBuilding)
  }

  static func failed(_ error: any Error) -> Self {
    Self(value: .failed(error))
  }

  static func building(_ building: Building) -> Self {
    let image = Image(building.id, bundle: .buildingsViews)
    return Self(value: .building(building, image: image))
  }

}

extension Timeline<BuildingTimelineProvider.Entry> {
  static var missingBuilding: Self {
    Self(entries: [.missingBuilding], policy: .never)
  }

  static func failed(_ error: any Error) -> Self {
    Self(entries: [.failed(error)], policy: .after(.now + errorRetryInterval))
  }

  static func building(_ building: Building) -> Self {
    // We currently only reload the timeline after the scraper runs
    let reloadPolicy = TimelineReloadPolicy.after(.now + DevSoc.scraperFrequency)
    return Self(entries: [.building(building)], policy: reloadPolicy)
  }
}
