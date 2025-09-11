//
//  LiveSwiftDataRoomLoader.swift
//  Rooms
//
//  Created by Chris Wong on 3/9/2025.
//

import Foundation
import Persistence
import RoomModels

// MARK: - SwiftDataRoomLoader

public protocol SwiftDataRoomLoader {
  func fetch() -> Result<[Room], RoomLoaderError>
  func seed(_ rooms: [Room]) -> Result<Void, RoomLoaderError>
}

// MARK: - LiveSwiftDataRoomLoader

public final class LiveSwiftDataRoomLoader: SwiftDataRoomLoader {

  // MARK: Lifecycle

  public init(swiftDataStore: some PersistentStore<SwiftDataRoom>) {
    self.swiftDataStore = swiftDataStore
  }

  // MARK: Public

  public func seed(_ rooms: [Room]) -> Result<Void, RoomLoaderError> {
    do {
      /// Ensure seed is only run once
      guard try swiftDataStore.size() == 0 else {
        return .failure(.alreadySeeded)
      }

      try swiftDataStore.save(rooms.map {
        SwiftDataRoom(
          abbreviation: $0.abbreviation,
          accessibility: $0.accessibility,
          audioVisual: $0.audioVisual,
          buildingId: $0.buildingId,
          capacity: $0.capacity,
          floor: $0.floor,
          id: $0.id,
          infoTechnology: $0.infoTechnology,
          latitude: $0.latitude,
          longitude: $0.longitude,
          microphone: $0.microphone,
          name: $0.name,
          school: $0.school,
          seating: $0.seating,
          usage: $0.usage,
          service: $0.service,
          writingMedia: $0.writingMedia)
      })
      return .success(())
    } catch {
      return .failure(.persistenceError)
    }
  }

  public func fetch() -> Result<[Room], RoomLoaderError> {
    do {
      let swiftDataRooms = try swiftDataStore.fetchAll()

      if swiftDataRooms.isEmpty {
        return .failure(.noDataAvailable)
      }

      let rooms = swiftDataRooms.map { $0.toRoom() }
      return .success(rooms)

    } catch {
      return .failure(.persistenceError)
    }
  }

  // MARK: Private

  private let swiftDataStore: any PersistentStore<SwiftDataRoom>
}
