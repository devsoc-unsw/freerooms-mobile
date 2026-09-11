//
//  BuildingWidgetConfigurationEntity.swift
//  Freerooms
//
//  Created by Matthew Yuen on 11/9/2026.
//

import AppIntents
import BuildingModels
import BuildingServices

struct BuildingWidgetConfigurationEntity: AppEntity {
  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Building")
  
  typealias Query = BuildingWidgetConfigurationEntityQuery
  
  let id: String
  let name: String
  
  static let defaultQuery = Query()
  
  init(id: String, name: String) {
    self.name = name
    self.id = id
  }
  
  init(from building: Building) {
    self.id = building.id
    self.name = building.name
  }
  
  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)",
      subtitle: "\(id)")
  }
  
  static let quadrangle = BuildingWidgetConfigurationEntity(id: "K-E15", name: "Quadrangle")
  
}

extension Building {
  nonisolated var buildingConfigurationEntity: BuildingWidgetConfigurationEntity {
    BuildingWidgetConfigurationEntity(from: self)
  }
}

final actor BuildingWidgetConfigurationEntityQuery: EntityQuery, EntityStringQuery {
  typealias Entity = BuildingWidgetConfigurationEntity
  
  private let buildingLoader: some BuildingLoader = LiveGraphQLBuildingLoader.default
  private var savedBuildings: [BuildingWidgetConfigurationEntity]?
  
  func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
    let identifierSet = Set(identifiers)
    return try await _getBuildings().filter { identifierSet.contains($0.id) }
  }
  
  func suggestedEntities() async throws -> [Entity] {
    return try await _getBuildings()
  }
  
  func entities(matching string: String) async throws -> [Entity] {
    return try await _getBuildings()
      .filter {
        $0.id.localizedStandardContains(string) ||
        $0.name.localizedStandardContains(string)
      }
  }
  
  private func _getBuildings() async throws -> [BuildingWidgetConfigurationEntity] {
    if let savedBuildings {
      return savedBuildings
    }
    
    let buildings = try await buildingLoader.fetch().get()
    savedBuildings = buildings.map(\.buildingConfigurationEntity)
    return savedBuildings!
  }
  
}
