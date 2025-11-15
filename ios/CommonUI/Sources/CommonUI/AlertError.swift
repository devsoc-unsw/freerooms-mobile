//
//  AlertError.swift
//  CommonUI
//
//  Created by Dicko Evaldo on 25/10/2025.
//
import Foundation

nonisolated
public struct AlertError: Identifiable {
  public let id = UUID()
  public let title: String
  public let message: String

  public init(title: String = "Error", message: String) {
    self.title = title
    self.message = message
  }
}
