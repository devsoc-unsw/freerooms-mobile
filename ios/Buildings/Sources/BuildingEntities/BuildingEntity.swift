//
//  BuildingEntity.swift
//  Buildings
//
//  Created by Matthew Yuen on 6/9/2026.
//

import Apollo
import AppIntents
import RoomServices
import BuildingModels
import BuildingServices
import Networking

public struct BuildingEntity: AppEntity {
  public static let defaultQuery = Query()
  
  @Property(title: "Name")
  public var name: String
  
  @Property(title: "ID")
  public var id: String
  
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
  
  public init(from building: Building) {
    self.name = building.name
    self.id = building.id
    self.latitude = building.latitude
    self.longitude = building.longitude
    self.aliases = building.aliases
    self.numberOfAvailableRooms = building.numberOfAvailableRooms
    self.overallRating = building.overallRating
  }
  
  public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Building")
  
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

extension BuildingEntity {
  
  public final actor Query: EntityStringQuery {
    public typealias Entity = BuildingEntity
    
    private let buildingLoader: LiveGraphQLBuildingLoader
    
    /// The cached result is primarily used to make sure that we don't make a
    /// network request every time the user changes a character while searching
    private var cachedResult: CachedResult?
    
    private struct CachedResult {
      let timestamp = Date()
      var buildings: [Building]
      
      var isStale: Bool {
        let staleThreshold = DevSoc.scraperFrequency
        return (timestamp + staleThreshold) < .now
      }
      
    }
    
    public init() {
      let backendURL = DevSoc.defaultBackendURL
      let session = URLSession(configuration: .default)
      let httpClient = URLSessionHTTPClient(session: session)
      let apolloStore = ApolloStore()
      
      let buildingsCache: (any BuildingsCache)?
      do {
        buildingsCache = try FileBackedCodable.sharedBuildingsCache.get()
      } catch {
        buildingsCache = nil
      }
      
      let buildingLoader = LiveGraphQLBuildingLoader(
        client: DevSoc.createLiveApolloClient(using: apolloStore),
        roomStatusLoader: LiveRoomStatusLoader(
          client: httpClient,
          baseURL: backendURL),
        buildingRatingLoader: RemoteBuildingRatingLoader(
          client: httpClient,
          baseURL: backendURL),
        buildingsCache: buildingsCache)
      
      self.buildingLoader = buildingLoader
    }
    
    public func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
      let identifierSet = Set(identifiers)
      return try await _getBuildings()
        .filter { identifierSet.contains($0.id) }
        .map(\.appEntity)
    }
    
    public func entities(matching string: String) async throws -> [Entity] {
      return try await _getBuildings()
        .filter({
          $0.name.localizedStandardContains(string) ||
          $0.id.localizedStandardContains(string)
        })
        .map(\.appEntity)
    }
    
    public func suggestedEntities() async throws -> [Entity] {
      return try await _getBuildings().map(\.appEntity)
    }
    
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
  
}
