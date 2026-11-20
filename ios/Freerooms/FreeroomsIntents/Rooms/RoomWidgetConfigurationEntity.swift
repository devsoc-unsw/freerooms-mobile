//
//  RoomWidgetConfigurationEntity.swift
//  Freerooms
//
//  Created by Matthew Yuen on 19/9/2026.
//

import AppIntents
import RoomModels
import RoomServices

// MARK: - RoomWidgetConfigurationEntity

struct RoomWidgetConfigurationEntity: AppEntity {

  // MARK: Lifecycle

  init(id: String, buildingId: String, name: String) {
    self.id = id
    self.buildingId = buildingId
    self.name = name
  }

  init(from room: Room) {
    id = room.id
    buildingId = room.buildingId
    name = room.name
  }

  // MARK: Internal

  typealias DefaultQuery = RoomWidgetConfigurationEntityQuery

  static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Room")

  static let defaultQuery = DefaultQuery()

  let id: String
  let buildingId: String
  let name: String

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(
      title: "\(name)",
      subtitle: "\(id) - \(buildingId)")
  }

}

extension Room {
  var widgetConfigurationEntity: RoomWidgetConfigurationEntity {
    RoomWidgetConfigurationEntity(from: self)
  }
}

// MARK: - RoomWidgetConfigurationEntityQuery

final actor RoomWidgetConfigurationEntityQuery: EntityQuery, EntityStringQuery {

  // MARK: Internal

  typealias Entity = RoomWidgetConfigurationEntity

  func entities(for identifiers: [Entity.ID]) async throws -> [Entity] {
    let identifierSet = Set(identifiers)
    return try await _getRooms().filter { identifierSet.contains($0.id) }
  }

  func suggestedEntities() async throws -> [Entity] {
    try await _getRooms()
  }

  func entities(matching string: String) async throws -> [Entity] {
    try await _getRooms()
      .filter {
        $0.id.localizedStandardContains(string) ||
          $0.name.localizedStandardContains(string)
      }
  }

  func defaultResult() async -> Entity? {
    nil
  }

  // MARK: Private

  private let roomLoader: some RoomLoader = LiveGraphQLRoomLoader.default
  private var savedRooms: [Entity]?

  private func _getRooms() async throws -> [Entity] {
    if let savedRooms {
      return savedRooms
    }

    let rooms = try await roomLoader.fetch().get()
    savedRooms = rooms.map(\.widgetConfigurationEntity)
    return savedRooms!
  }

}
