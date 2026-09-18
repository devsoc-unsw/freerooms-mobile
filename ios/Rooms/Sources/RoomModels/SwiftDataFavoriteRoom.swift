//
//  SwiftDataFavoriteRoom.swift
//  Rooms
//
//  Created by Matthew Yuen on 17/4/2026.
//

public import Foundation
import Persistence
public import SwiftData

@Model
public final class SwiftDataFavoriteRoom {

  // MARK: Lifecycle

  public init(roomID: Room.ID, createdAt: Date = .now) {
    self.roomID = roomID
    self.createdAt = createdAt
  }

  // MARK: Public

  public var roomID: Room.ID
  public var createdAt: Date

}
