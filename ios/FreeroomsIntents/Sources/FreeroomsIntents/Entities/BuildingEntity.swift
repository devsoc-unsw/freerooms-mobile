//
//  BuildingEntity.swift
//  Buildings
//
//  Created by Matthew Yuen on 6/9/2026.
//

import Apollo
import AppIntents
import BuildingModels
import BuildingServices
import Networking
import RoomServices

// MARK: - BuildingEntity

public struct BuildingEntity: AppEntity {

  // MARK: Lifecycle

  public init(from building: Building) {
    id = building.id
    name = building.name
    buildingId = building.id
    latitude = building.latitude
    longitude = building.longitude
    aliases = building.aliases
    numberOfAvailableRooms = building.numberOfAvailableRooms
    overallRating = building.overallRating
  }

  // MARK: Public

  public static let defaultQuery = BuildingEntityQuery()

  public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Building")
  
  /// For the `Identifiable` protocol
  public let id: String

  @Property(title: "Name")
  public var name: String

  @Property(title: "ID")
  public var buildingId: String

  @Property(title: "Latitiude")
  public var latitude: Double

  @Property(title: "Longitude")
  public var longitude: Double

  @Property(title: "Aliases")
  public var aliases: [String]

  @Property(title: "Available Rooms")
  public var numberOfAvailableRooms: Int?

  @Property(title: "Overall Rating")
  public var overallRating: Double?

  public var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)",
      subtitle: "\(id)")
  }

}

extension Building {

  public nonisolated var appEntity: BuildingEntity {
    BuildingEntity(from: self)
  }

}

public final actor BuildingEntityQuery: EntityStringQuery {
  
  // MARK: Lifecycle
  
  public init() {
    buildingLoader = LiveGraphQLBuildingLoader.default
  }
  
  // MARK: Public
  
  public typealias Entity = BuildingEntity
  
  public func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
    let identifierSet = Set(identifiers)
    return try await _getBuildings()
      .filter { identifierSet.contains($0.id) }
      .map(\.appEntity)
  }
  
  public func entities(matching string: String) async throws -> [Entity] {
    try await _getBuildings()
      .filter {
        $0.name.localizedStandardContains(string) ||
        $0.id.localizedStandardContains(string)
      }
      .map(\.appEntity)
  }
  
  public func suggestedEntities() async throws -> [Entity] {
    try await _getBuildings().map(\.appEntity)
  }
  
  // MARK: Private
  
  private struct CachedResult {
    let timestamp = Date()
    var buildings: [Building]
    
    var isStale: Bool {
      let staleThreshold = DevSoc.scraperFrequency
      return (timestamp + staleThreshold) < .now
    }
    
  }
  
  private let buildingLoader: LiveGraphQLBuildingLoader
  
  /// The cached result is primarily used to make sure that we don't make a
  /// network request every time the user changes a character while searching
  private var cachedResult: CachedResult?
  
  private func _getBuildings() async throws -> [Building] {
    // Check if the cached results are still valid
    if let cachedResult, !cachedResult.isStale {
      return cachedResult.buildings
    }
    
    // Otherwise fetch new buildings and update cache
    let buildings = try await buildingLoader.fetch().get()
    cachedResult = CachedResult(buildings: buildings)
    return buildings
  }
  
}
