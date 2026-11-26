//
//  RootTabsNavigationScene.swift
//  CommonUI
//
//  Created by Matthew Yuen on 26/11/2026.
//

public import VISOR

public struct RootTabsNavigationScene: NavigationScene {

  public enum Push: PushDestination {
    // No push destinations
  }

  public enum Root: RootDestination {
    case buildings
    case map
    case rooms
    case bookings
  }

}
