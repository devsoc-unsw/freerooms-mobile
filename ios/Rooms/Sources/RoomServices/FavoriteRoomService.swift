//
//  FavoriteRoomService.swift
//  Rooms
//
//  Created by Matthew Yuen on 17/4/2026.
//

import RoomModels
import SwiftData
import VISOR

// MARK: - FavoriteRoomService

@Spyable
@Stubbable
public protocol FavoriteRoomService: AnyObject {

  /// Adds a new favorite
  ///
  /// If the room is already favorited, this method does nothing.
  func addFavorite(roomID: Room.ID)

  /// Checks if a room is favorited
  func isFavorite(roomID: Room.ID) -> Bool

  /// Returns the list of favorited rooms
  func getAllFavoriteRoomIds() -> [Room.ID]
}

// MARK: - SwiftDataFavoriteRoomService

/// Provides the current favorites.
///
/// > Warning:
/// > Only create one of these services, otherwise the favorites may not be accurate.
@Observable
public final class SwiftDataFavoriteRoomService: FavoriteRoomService {

  // MARK: Lifecycle

  public init(context: ModelContext) throws {
    self.context = context
    favoriteRoomIDs = try Set(context.fetch(Self._fetchDescriptor).map(\.roomID))
  }

  // MARK: Public

  public let context: ModelContext
  public var favoriteRoomIDs: Set<Room.ID>

  public func addFavorite(roomID: Room.ID) {
    // Check if the room is already favorited
    guard !favoriteRoomIDs.contains(roomID) else { return }

    // Otherwise add the new room
    let favoriteRoom = SwiftDataFavoriteRoom(roomID: roomID)
    context.insert(favoriteRoom)
    favoriteRoomIDs.insert(roomID)
  }

  public func isFavorite(roomID: Room.ID) -> Bool {
    favoriteRoomIDs.contains(roomID)
  }

  public func getAllFavoriteRoomIds() -> [Room.ID] {
    Array(favoriteRoomIDs)
  }

  /// Saves changes and refetches
  public func sync() throws {
    try context.save()
    favoriteRoomIDs = try Set(context.fetch(Self._fetchDescriptor).map(\.roomID))
  }

  // MARK: Private

  static private var _fetchDescriptor: FetchDescriptor<SwiftDataFavoriteRoom> {
    FetchDescriptor<SwiftDataFavoriteRoom>()
  }

}
