//
//  BuildingImage.swift
//  Buildings
//
//  Created by Dicko Evaldo on 20/6/2025.
//

import CommonUI
import SwiftUI

public enum BuildingImage {
  public static subscript(buildingID: String, size: ImageSize = .medium) -> CachedImage {
    CachedImage(
      name: buildingID,
      bundle: .module,
      size: size)
  }
}
