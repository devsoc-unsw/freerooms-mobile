//
//  GenericCardViewItem.swift
//  CommonUI
//
//  Created by Gabriella Lianti on 15/10/25.
//

import BuildingModels
import RoomModels
import RoomViewModels
import SwiftUI

// MARK: - WidthPreferenceKey

public struct WidthPreferenceKey: PreferenceKey {
  public static let defaultValue: CGFloat = 0
  public static func reduce(
    value: inout CGFloat,
    nextValue: () -> CGFloat)
  {
    value = max(value, nextValue())
  }
}

// MARK: - GenericCardViewItem

public struct GenericCardViewItem<T: Equatable & Hashable & Identifiable & HasName & HasRating>: View {

  // MARK: Lifecycle

  public init(cardWidth: Binding<CGFloat?>, item: T) {
    _cardWidth = cardWidth
    self.item = item
  }

  // MARK: Public

  public var body: some View {
    VStack(spacing: GenericCardViewItemLayout.contentSpacing) {
      HStack(alignment: .center, spacing: 0) {
        if let room = item as? Room {
          Text(room.abbreviation)
            .font(.system(size: GenericCardViewItemLayout.titleFontSize, weight: .bold))
            .foregroundStyle(theme.label.primary)
            .lineLimit(1)
            .truncationMode(.tail)

        } else if let building = item as? Building {
          Text(building.name)
            .font(.system(size: GenericCardViewItemLayout.titleFontSize, weight: .bold))
            .foregroundStyle(theme.label.primary)
            .lineLimit(1)
            .truncationMode(.tail)
        }

        Spacer()
        if let overallRating = item.overallRating {
          HStack(spacing: 0) {
            Text(overallRating.formatted())
              .foregroundStyle(.white)
              .font(.system(size: GenericCardViewItemLayout.ratingFontSize, weight: .semibold))
              .padding(.leading, GenericCardViewItemLayout.badgeInnerLeadingPadding)
            Image(systemName: "star.fill")
              .font(.system(size: GenericCardViewItemLayout.ratingIconSize, weight: .semibold))
              .foregroundStyle(.white)
          }
          .padding(.horizontal, GenericCardViewItemLayout.badgeHorizontalPadding)
          .padding(.vertical, GenericCardViewItemLayout.badgeVerticalPadding)
          .background(
            RoundedRectangle(cornerRadius: GenericCardViewItemLayout.ratingBadgeCornerRadius)
              .fill(theme.label.tertiary))
        } else {
          HStack(spacing: 0) {
            Text("0")
              .foregroundStyle(.white)
              .font(.system(size: GenericCardViewItemLayout.ratingFontSize, weight: .semibold))
              .padding(.leading, GenericCardViewItemLayout.badgeInnerLeadingPadding)
            Image(systemName: "star.fill")
              .font(.system(size: GenericCardViewItemLayout.ratingIconSize, weight: .semibold))
              .foregroundStyle(.white)
          }
          .padding(.horizontal, GenericCardViewItemLayout.badgeHorizontalPadding)
          .padding(.vertical, GenericCardViewItemLayout.badgeVerticalPadding)
          .background(
            RoundedRectangle(cornerRadius: GenericCardViewItemLayout.ratingBadgeCornerRadius)
              .fill(theme.label.tertiary))
        }
      }

      HStack(alignment: .center, spacing: 0) {
        if let room = item as? Room {
          let isFilterActive = roomViewModel.selectedDate != DateDefaults.selectedDate
          let bookings = roomViewModel.bookingsByRoomId[room.id]
          Text(room.statusTextWhenFiltering(
            referenceInstant: roomViewModel.selectedDate,
            isCustomFilterActive: isFilterActive,
            bookings: bookings))
            .font(.system(size: 12, weight: .light))
            .foregroundStyle(room.contextualStatusTextColour(
              referenceInstant: roomViewModel.selectedDate,
              isCustomFilterActive: isFilterActive,
              bookings: bookings))
            .padding(.vertical, GenericCardViewItemLayout.badgeVerticalPadding)
            .padding(.horizontal, GenericCardViewItemLayout.badgeHorizontalPadding)
            .frame(maxWidth: .infinity)
            .background(
              RoundedRectangle(cornerRadius: GenericCardViewItemLayout.statusBadgeCornerRadius)
                .fill(room.contextualStatusBackgroundColor(
                  referenceInstant: roomViewModel.selectedDate,
                  isCustomFilterActive: isFilterActive,
                  bookings: bookings)))
        } else if let building = item as? Building {
          Text("^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true) available")
            .font(.system(size: GenericCardViewItemLayout.subtitleFontSize, weight: .light))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
    .padding(.horizontal, GenericCardViewItemLayout.contentHorizontalPadding)
    .padding(.vertical, GenericCardViewItemLayout.contentVerticalPadding)
    .background(GeometryReader { geometry in
      // In a background the GeometryReader expands to the bounds of the foreground view
      Color.clear.preference(
        key: WidthPreferenceKey.self,
        value: geometry.size.width)
    })
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
  @Environment(LiveRoomViewModel.self) private var roomViewModel

  @Binding private var cardWidth: CGFloat?

  private let item: T

}

// MARK: - GenericCardViewItemLayout

private enum GenericCardViewItemLayout {
  static let badgeHorizontalPadding: CGFloat = 4
  static let badgeInnerLeadingPadding: CGFloat = 2
  static let badgeVerticalPadding: CGFloat = 2
  static let contentHorizontalPadding: CGFloat = 12
  static let contentSpacing: CGFloat = 6
  static let contentVerticalPadding: CGFloat = 6
  static let ratingBadgeCornerRadius: CGFloat = 12
  static let ratingFontSize: CGFloat = 12
  static let ratingIconSize: CGFloat = 10
  static let statusBadgeCornerRadius: CGFloat = 5
  static let subtitleFontSize: CGFloat = 14
  static let titleFontSize: CGFloat = 16
}

#Preview {
  @Previewable @State var width: CGFloat? = nil
  let viewModel: LiveRoomViewModel = PreviewRoomViewModel()

  GenericCardViewItem(
    cardWidth: $width,
    item: Room.exampleOne)
    .defaultTheme()
    .environment(viewModel)
}
