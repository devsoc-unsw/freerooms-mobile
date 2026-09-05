//
//  BuildingEntity.swift
//  Buildings
//
//  Created by Matthew Yuen on 6/9/2026.
//

import AppIntents

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
  
  public var appEntity: BuildingEntity {
    BuildingEntity(from: self)
  }
  
}

extension BuildingEntity {
  
  public struct Query: EntityStringQuery {
    public typealias Entity = BuildingEntity
    
    public init() {}
    
    public func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
      fatalError()
    }
    
    public func entities(matching string: String) async throws -> [Entity] {
      fatalError()
    }
    
    public func suggestedEntities() async throws -> [Entity] {
      fatalError()
    }
    
  }
  
}
