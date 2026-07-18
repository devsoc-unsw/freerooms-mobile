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

  // MARK: - Room Lists

  static let backgroundOpacity = 0.1
  static let buildingHeroImageCornerRadius: CGFloat = 15
  static let buildingHeroImageHeightFraction: CGFloat = 0.25
  static let cardGridSpacing: CGFloat = 24
  static let cardShadowOpacity = 0.2
  static let cardShadowRadius: CGFloat = 5
  static let contentHorizontalPadding: CGFloat = 16
  static let filterMenuAnimationDuration = 0.25
  static let filterMenuBottomPadding: CGFloat = 8
  static let filterMenuScrimOpacity = 0.42
  static let filterMenuTrailingPadding: CGFloat = 16
  static let listRowVerticalPadding: CGFloat = 5
  static let sectionHeaderLeadingPadding: CGFloat = 10
  static let sectionHeaderTopPadding: CGFloat = 10

}
