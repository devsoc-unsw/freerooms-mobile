//
//  DistanceFromUser.swift
//  CommonUI
//
//  Created by Eric Wong on 21/11/2026.
//

import BuildingModels
import RoomModels
public import SwiftUI

// MARK: - Distance lookup

/// How far the user is from a room or a building. `nil` for other items and when there's no
/// location.
func distanceFromUser(
  to item: some Any,
  roomDistances: [String: Double],
  buildingDistances: [String: Double])
  -> Double?
{
  if let room = item as? Room {
    return roomDistances[room.id]
  }
  if let building = item as? Building {
    return buildingDistances[building.id]
  }
  return nil
}

// MARK: - Environment

extension EnvironmentValues {
  /// How far the user is from each building, in metres, keyed by building ID. Empty when there's
  /// no location permission or GPS fix, so room and building tiles show no distance.
  @Entry public var distanceFromUserByBuildingID: [String: Double] = [:]

  /// How far the user is from each room, in metres, keyed by room ID. Empty when there's no
  /// location permission or GPS fix.
  @Entry public var distanceFromUserByRoomID: [String: Double] = [:]
}
