//
//  FreeroomsNavigationScene.swift
//  CommonUI
//
//  Created by Matthew Yuen on 26/11/2026.
//

public import BookingModels
public import BuildingModels
public import RoomModels
public import VISOR

public struct FreeroomsNavigationScene: NavigationScene {
  public typealias Router = VISOR::Router<Self>

  public enum Push: PushDestination {
    case room(id: Room.ID)
    case building(id: Building.ID)
    case booking(id: WeeklyBooking.ID)
  }

  public typealias Root = FreeroomsTab
}
