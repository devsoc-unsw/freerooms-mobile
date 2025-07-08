//
//  File.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

import SwiftUI

public struct RoomsTabView: View {
  @State var selectedTab = "Buildings"

  public init() { }

  public var body: some View {
    Text("Rooms tab")
      .tabItem {
        Label("Rooms", systemImage: selectedTab == "Rooms" ? "door.left.hand.open" : "door.left.hand.closed")
      }
      .tag("Rooms")
  }
}

#Preview {
  RoomsTabView()
}
