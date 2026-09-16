//
//  DateDefaults.swift
//  Rooms
//
//  Created by Yanlin Li  on 18/5/2026.
//

public import Foundation
import os

public enum DateDefaults {
  private static let _selectedDateStorage = OSAllocatedUnfairLock(initialState: Date())

  public static var selectedDate: Date {
    get { _selectedDateStorage.withLock(\.self) }
    set { _selectedDateStorage.withLock { $0 = newValue } }
  }
}
