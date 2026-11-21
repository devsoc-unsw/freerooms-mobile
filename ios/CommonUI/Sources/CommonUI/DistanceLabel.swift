//
//  DistanceLabel.swift
//  CommonUI
//
//  Created by Eric Wong on 21/11/2026.
//

public import SwiftUI

// MARK: - DistanceLabel

/// A distance with a location arrow in front. The arrow marks it as a distance,
/// so "80 m" isn't read as minutes.
public struct DistanceLabel: View {

  // MARK: Lifecycle

  public init(metres: Double) {
    self.metres = metres
  }

  // MARK: Public

  public var body: some View {
    // A plain HStack rather than a Label, whose icon-to-title gap is too wide here.
    HStack(spacing: DistanceLabelLayout.iconSpacing) {
      Image(systemName: "location.fill")
        .imageScale(.small)
      Text(Self.formatted(metres: metres))
    }
    .fontWeight(.semibold)
    .foregroundStyle(theme.accent.primary)
    .lineLimit(1)
    .fixedSize()
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("\(Self.formatted(metres: metres)) away")
  }

  /// The distance for display, e.g. "120 m" or "1.2 km", in the user's local units.
  public static func formatted(metres: Double) -> String {
    Measurement(value: metres, unit: UnitLength.meters)
      .formatted(.measurement(width: .abbreviated, usage: .road))
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private let metres: Double

}

// MARK: - DistanceBadge

/// The distance on a card's photo: a small capsule with the arrow and distance, e.g. "➤ 120 m".
public struct DistanceBadge: View {

  // MARK: Lifecycle

  public init(metres: Double) {
    self.metres = metres
  }

  // MARK: Public

  public var body: some View {
    HStack(spacing: DistanceLabelLayout.iconSpacing) {
      Image(systemName: "location.fill")
        .imageScale(.small)
      Text(DistanceLabel.formatted(metres: metres))
    }
    .font(.caption.weight(.semibold))
    .foregroundStyle(theme.label.primary)
    .lineLimit(1)
    .fixedSize()
    .padding(.vertical, DistanceLabelLayout.badgeVerticalPadding)
    .padding(.horizontal, DistanceLabelLayout.badgeHorizontalPadding)
    .background(.thinMaterial, in: Capsule())
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("\(DistanceLabel.formatted(metres: metres)) away")
  }

  // MARK: Private

  @Environment(Theme.self) private var theme

  private let metres: Double

}

// MARK: - DistanceSortLabel

/// The "Distance" row in a sort menu, with a hint underneath when there's no location to sort by.
/// Put it in a menu `Button` or `Toggle` and disable that control when `canSortByDistance` is false.
public struct DistanceSortLabel: View {

  // MARK: Lifecycle

  public init(canSortByDistance: Bool) {
    self.canSortByDistance = canSortByDistance
  }

  // MARK: Public

  public var body: some View {
    // Title, subtitle and icon: the form menus show as a two-line row.
    Text("Distance")
    if !canSortByDistance {
      Text("Turn on location in Settings")
    }
    Image(systemName: "location.fill")
  }

  // MARK: Private

  private let canSortByDistance: Bool

}

// MARK: - DistanceAndAvailableRooms

/// A building's distance and free rooms, e.g. "➤ 120 m · 9 rooms available", shortened to
/// "9 available" when space is short. Leaves out the count when it isn't known.
public struct DistanceAndAvailableRooms: View {

  // MARK: Lifecycle

  public init(metres: Double, availableRooms: Int?) {
    self.metres = metres
    self.availableRooms = availableRooms
  }

  // MARK: Public

  public var body: some View {
    HStack(spacing: DistanceLabelLayout.detailSpacing) {
      DistanceLabel(metres: metres)
      if let availableRooms {
        Text("·")
        // Uses the first one that fits: two-digit counts don't fit in full next to the distance.
        ViewThatFits(in: .horizontal) {
          Text("^[\(availableRooms) room](inflect: true) available")
          Text("\(availableRooms) available")
        }
      }
    }
    .lineLimit(1)
  }

  // MARK: Private

  private let metres: Double
  private let availableRooms: Int?

}

// MARK: - DistanceLabelLayout

enum DistanceLabelLayout {
  static let badgeHorizontalPadding: CGFloat = 8
  /// How far the badge sits in from the corner of a card's photo.
  static let badgeInset: CGFloat = 8
  static let badgeVerticalPadding: CGFloat = 4
  static let detailSpacing: CGFloat = 4
  static let iconSpacing: CGFloat = 4
}

#Preview {
  VStack {
    DistanceLabel(metres: 80)
    DistanceLabel(metres: 1240)
    DistanceBadge(metres: 80)
    DistanceAndAvailableRooms(metres: 120, availableRooms: 9)
  }
  .defaultTheme()
}
