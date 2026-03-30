//
//  RoomImage.swift
//  Rooms
//
//  Created by Yanlin on 23/6/2025.
//

import CommonUI
import SwiftUI

public enum RoomImage {
  public static subscript(roomID: String, size: ImageSize = .medium) -> CachedImage {
    CachedImage(
      name: roomID,
      bundle: .module,
      size: size,
      fallbackName: "default")
  }
}
