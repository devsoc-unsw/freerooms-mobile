//
//  BookingViewLayout.swift
//  Bookings
//
//  Created by Yanlin Li  on 8/8/2025.
//

import SwiftUI

enum BookingViewLayout {
  // Constants for BookingsListView
  static let bookingListRowContentHorizontalPadding: CGFloat = 16
  static let bookingsListSectionVerticalPadding: CGFloat = 4
  static let refreshIndicatorPadding: CGFloat = 8

  /// Constants for BookingListRowContentView
  static let rowGap: CGFloat = 4

  static let rowIconGap: CGFloat = 6
  static let rowIconImageWidth: CGFloat = 18
  static let rowCapacityCapsulePadding: CGFloat = 6
  static let rowCapacityCapsuleBackgroundOpacity: CGFloat = 0.15

  static let rowHorizontalSpacing: CGFloat = 8
  static let rowContentSpacing: CGFloat = 5
  static let rowEndTimeOpacity: CGFloat = 0.8

  static let rowMainContentDividerBottomPadding: CGFloat = 4

  // Constants for BookingDetailsSheet
  static let detailsPadding: CGFloat = 20
  static let detailsSectionSpacing: CGFloat = 24
  static let detailsImageRadius: CGFloat = 16
  static let detailsImageSize: CGFloat = 112
  static let detailsFieldSpacing: CGFloat = 20

  // Constants for BookingHeader and BookingInformation
  static let detailsHeaderSpacing: CGFloat = 16
  static let detailsHeaderTextSpacing: CGFloat = 8
  static let detailLabelSpacing: CGFloat = 6
  static let detailsColumnCount = 2
  static let detailsAccessibilityColumnCount = 1

  // Constants for BookingFacilities
  static let facilitiesSectionSpacing: CGFloat = 16
  static let facilitiesHeaderMinimumSpacing: CGFloat = 8
  static let facilitiesPreviewCount = 4
  static let facilitiesGridSpacing: CGFloat = 12
  static let facilityContentSpacing: CGFloat = 10
  static let facilityIconHeight: CGFloat = 28
  static let facilityPadding: CGFloat = 16
  static let facilityMinimumHeight: CGFloat = 104
  static let facilityCornerRadius: CGFloat = 18

  static func detailColumns(for dynamicTypeSize: DynamicTypeSize) -> [GridItem] {
    Array(
      repeating: GridItem(.flexible(), alignment: .topLeading),
      count: dynamicTypeSize.isAccessibilitySize ? detailsAccessibilityColumnCount : detailsColumnCount)
  }
}
