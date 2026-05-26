//
//  RoomLayoutConstants.swift
//  Rooms
//

import SwiftUI

enum RoomLayoutConstants {

  // MARK: - Room Details Sheet

  static let sheetSmallDetent = PresentationDetent.fraction(0.65)
  static let sheetMediumDetent = PresentationDetent.fraction(0.75)
  static let imageHeightFraction: CGFloat = 0.4
  static let bookingSectionCornerRadius: CGFloat = 12
  static let dismissDragMinimumDistance: CGFloat = 20
  static let dismissDragMinimumWidth: CGFloat = 50

  // MARK: - Booking Grid

  static let slotHeight: CGFloat = 60
  static let timeLabelWidth: CGFloat = 50
  static let scheduleStartHour: Int = 9
  static let scheduleEndHour: Int = 24

  // MARK: - Toolbar Icons

  static let toolbarSortIconWidth: CGFloat = 25
  static let toolbarIconHeight: CGFloat = 20
  static let toolbarViewToggleIconWidth: CGFloat = 22
  static let toolbarIconPadding: CGFloat = 5

}
