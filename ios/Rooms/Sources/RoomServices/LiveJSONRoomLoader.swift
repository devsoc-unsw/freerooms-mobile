//
//  LiveJSONRoomLoader.swift
//  Rooms
//
//  Created by Chris Wong on 5/8/2025.
//

import Foundation
import Persistence
import RoomModels

// MARK: - JSONRoomLoader

public protocol JSONRoomLoader {
  func fetch() -> Swift.Result<[Room], RoomLoaderError>
}

// MARK: - LiveJSONRoomLoader

public struct LiveJSONRoomLoader: JSONRoomLoader {

  // MARK: Lifecycle

  public init(using loader: any JSONLoader<[DecodableRoom]>) {
    self.loader = loader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Room], RoomLoaderError>

  public func fetch() -> Result {
    guard let roomsSeedJSONPath else {
      fatalError("Rooms seed JSON file not bundled")
    }

    switch loader.load(from: roomsSeedJSONPath) {
    case .success(let decodableRooms):
      let rooms = decodableRooms.map {
        Room(
          abbreviation: $0.abbr,
          accessibility: $0.accessibility,
          audioVisual: $0.audiovisual,
          buildingId: $0.buildingId,
          capacity: $0.capacity,
          floor: $0.floor ?? "",
          id: $0.id,
          infoTechnology: $0.infoTechnology,
          latitude: $0.lat,
          longitude: $0.long,
          microphone: $0.microphone,
          name: $0.name,
          school: $0.school,
          seating: $0.seating ?? "",
          usage: $0.usage,
          service: $0.service,
          writingMedia: $0.writingMedia)
      }
      return .success(rooms)

    case .failure(.fileNotFound):
      return .failure(.fileNotFound)

    case .failure(.malformedJSON):
      return .failure(.malformedJSON)
    }
  }

  // MARK: Internal

  var roomsSeedJSONPath: String? {
    Bundle.module.path(forResource: "RoomsSeed", ofType: "json")!
  }

  // MARK: Private

  private let loader: any JSONLoader<[DecodableRoom]>

}
