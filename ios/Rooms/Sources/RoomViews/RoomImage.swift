//
//  RoomImage.swift
//  Rooms
//
//  Created by Yanlin on 23/6/2025.
//

import SwiftUI

public enum RoomImage {
  public static subscript(roomID: String) -> Image {
    if let uiImage = UIImage(named: roomID, in: .module, with: nil) {
      Image(uiImage: uiImage)
    } else {
      Image("default", bundle: .module)
    }
  }
}
