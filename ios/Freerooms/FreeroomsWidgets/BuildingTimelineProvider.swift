//
//  BuildingTimelineProvider.swift
//  Freerooms
//
//  Created by Matthew Yuen on 7/9/2026.
//

import WidgetKit
import AppIntents
import FreeroomsIntents
import BuildingServices
import BuildingModels
import Networking

struct BuildingTimelineProvider: AppIntentTimelineProvider {
  
  struct Entry: TimelineEntry {
    let date = Date()
    let value: Value
    
    enum Value {
      case building(Building)
      case missingBuilding
      case failed(any Error)
    }
  }
  
  typealias Intent = BuildingConfigurationIntent
  
  init() {
    self.buildingLoader = .default
  }
  
  let buildingLoader: LiveGraphQLBuildingLoader
  
  func snapshot(for configuration: Intent, in context: Context) async -> Entry {
    fatalError()
  }
  
  func timeline(for configuration: Intent, in context: Context) async -> Timeline<Entry> {
    
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
  
  func placeholder(in context: Context) -> Entry {
    return .placeholder
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
    
    return Self(value: .building(previewBuilding))
  }
  
  static func failed(_ error: any Error) -> Self {
    return Self(value: .failed(error))
  }
  
  static func building(_ building: Building) -> Self {
    return Self(value: .building(building))
  }
  
  static var missingBuilding: Self {
    return Self(value: .missingBuilding)
  }
}

extension Timeline<BuildingTimelineProvider.Entry> {
  static func failed(_ error: any Error) -> Self {
    return Self(entries: [.failed(error)], policy: .never)
  }
  
  static var missingBuilding: Self {
    return Self(entries: [.missingBuilding], policy: .never)
  }
  
  static func building(_ building: Building) -> Self {
    
    // We currently only reload the timeline after the scraper runs
    let reloadPolicy = TimelineReloadPolicy.after(.now + DevSoc.scraperFrequency)
    
    return Self(entries: [.building(building)], policy: .never)
  }
}
