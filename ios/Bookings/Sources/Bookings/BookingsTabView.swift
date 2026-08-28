//
//  BookingsTabView.swift
//  Bookings
//
//  Created by Gabriella Lianti on 3/7/2026.
//

import SwiftUI
import CommonUI

public struct BookingsTabView: View {
  public init() { }

  public var body: some View {
    Text("Bookings tab :>")
      .tabItem {
        Label("Bookings", systemImage: "book.pages")
      }
      .tag(FreeroomsTab.bookings)
  }
}
