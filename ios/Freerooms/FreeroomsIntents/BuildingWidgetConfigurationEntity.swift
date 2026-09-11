//
//  BuildingWidgetConfigurationEntity.swift
//  Freerooms
//
//  Created by Matthew Yuen on 11/9/2026.
//

import AppIntents
import BuildingModels
import BuildingServices

// MARK: - BuildingWidgetConfigurationEntity

struct BuildingWidgetConfigurationEntity: AppEntity {

  // MARK: Lifecycle

  init(id: String, name: String) {
    self.name = name
    self.id = id
  }

  init(from building: Building) {
    id = building.id
    name = building.name
  }

  // MARK: Internal

  typealias DefaultQuery = BuildingWidgetConfigurationEntityQuery

  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Building")

  static let defaultQuery = DefaultQuery()

  static let quadrangle = BuildingWidgetConfigurationEntity(id: "K-E15", name: "Quadrangle")

  let id: String
  let name: String

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)",
      subtitle: "\(id)")
  }

}

extension Building {
  nonisolated var buildingConfigurationEntity: BuildingWidgetConfigurationEntity {
    BuildingWidgetConfigurationEntity(from: self)
  }
}

// MARK: - BuildingWidgetConfigurationEntityQuery

final actor BuildingWidgetConfigurationEntityQuery: EntityQuery, EntityStringQuery {

  // MARK: Internal

  typealias Entity = BuildingWidgetConfigurationEntity

  func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
    let identifierSet = Set(identifiers)
    return try await _getBuildings().filter { identifierSet.contains($0.id) }
  }

  func suggestedEntities() async throws -> [Entity] {
    try await _getBuildings()
  }

  func entities(matching string: String) async throws -> [Entity] {
    try await _getBuildings()
      .filter {
        $0.id.localizedStandardContains(string) ||
          $0.name.localizedStandardContains(string)
      }
  }

  func defaultResult() async -> Entity? {
    .quadrangle
  }

  // MARK: Private

  private let buildingLoader: some BuildingLoader = LiveGraphQLBuildingLoader.default
  private var savedBuildings: [BuildingWidgetConfigurationEntity]?

  private func _getBuildings() async throws -> [BuildingWidgetConfigurationEntity] {
    if let savedBuildings {
      return savedBuildings
    }

    let buildings = try await buildingLoader.fetch().get()
    savedBuildings = buildings.map(\.buildingConfigurationEntity)
    return savedBuildings!
  }

}
