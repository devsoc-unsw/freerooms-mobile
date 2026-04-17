//
//  FavoriteRoomService.swift
//  Rooms
//
//  Created by Matthew Yuen on 17/4/2026.
//

import Foundation
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
  ///
  /// > Returns:
  /// > `true` if a new favorite was added,
  /// > otherwise `false` if the room was already favorited.
  @discardableResult
  func addFavorite(roomID: Room.ID) -> Bool

  /// Removes a favorite
  ///
  /// If the room was already unfavorited, this method does nothing.
  ///
  /// > Returns:
  /// > `true` if the favorite was removed,
  /// > otherwise `false` if the room was already unfavorited.
  @discardableResult
  func removeFavorite(roomID: Room.ID) -> Bool

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
    let favoriteRooms = try context.fetch(Self._fetchDescriptor)
    self.favoriteRooms = Dictionary(uniqueKeysWithValues: favoriteRooms.map { ($0.roomID, $0) })
  }

  // MARK: Public

  public let context: ModelContext

  @discardableResult
  public func addFavorite(roomID: Room.ID) -> Bool {
    // Check if the room is already favorited
    guard !favoriteRooms.keys.contains(roomID) else { return false }

    // Otherwise add the new room
    let favoriteRoom = SwiftDataFavoriteRoom(roomID: roomID)
    context.insert(favoriteRoom)
    favoriteRooms[roomID] = favoriteRoom

    return true
  }

  @discardableResult
  public func removeFavorite(roomID: Room.ID) -> Bool {
    // Check if the room is favorited. If it is, remove it
    guard let favorite = favoriteRooms.removeValue(forKey: roomID) else { return false }

    // Remove the room from favorites
    context.delete(favorite)

    return true
  }

  public func isFavorite(roomID: Room.ID) -> Bool {
    favoriteRooms.keys.contains(roomID)
  }

  public func getAllFavoriteRoomIds() -> [Room.ID] {
    Array(favoriteRooms.keys)
  }

  /// Saves changes and refetches
  ///
  /// > Warning:
  /// > Normally you should not need to call this function if you are using a single RoomService.
  /// > This is only necessary when you have multiple services, which you should not have in the first place.
  public func sync() throws {
    try context.save()
    let favoriteRooms = try context.fetch(Self._fetchDescriptor)
    self.favoriteRooms = Dictionary(uniqueKeysWithValues: favoriteRooms.map { ($0.roomID, $0) })
  }

  // MARK: Private

  static private var _fetchDescriptor: FetchDescriptor<SwiftDataFavoriteRoom> {
    FetchDescriptor<SwiftDataFavoriteRoom>()
  }

  private var favoriteRooms: [Room.ID: SwiftDataFavoriteRoom]

}
