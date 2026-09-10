//
//  Compatability.swift
//  Freerooms
//
//  Created by Matthew Yuen on 10/9/2026.
//

import SwiftUI
import WidgetKit

extension WidgetConfiguration {
  func polyfillPromptsForUserConfiguration() -> some WidgetConfiguration {
    if #available(iOS 18.0, *) {
      return promptsForUserConfiguration()
    } else {
      return self
    }
  }
}
