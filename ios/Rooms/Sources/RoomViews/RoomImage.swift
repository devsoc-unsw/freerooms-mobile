//
//  RoomImage.swift
//  Rooms
//
//  Created by Yanlin on 23/6/2025.
//

import SwiftUI

public enum RoomImage {
  public static subscript(roomID: String) -> Image {
    Image(roomID, bundle: .module)
  }
}
