//
//  ItemImage.swift
//  CommonUI
//
//  Created by Yanlin Li  on 4/8/2025.
//

import SwiftUI

public enum ItemImage {
  public static subscript(itemID: String, bundle: Bundle? = nil) -> Image {
    Image(itemID, bundle: bundle ?? Bundle.module)
  }
}
