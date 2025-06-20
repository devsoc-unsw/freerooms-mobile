//
//  File.swift
//  Buildings
//
//  Created by Dicko Evaldo on 20/6/2025.
//

import SwiftUI

public enum BuildingImage {
  static subscript(buildingID: String) -> Image {
    Image(buildingID, bundle: .module)
  }
}
