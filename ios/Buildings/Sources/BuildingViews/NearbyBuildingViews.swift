//
//  NearbyBuildingViews.swift
//  Buildings
//
//  Created by Eric Wong on 13/11/2026.
//

public import BuildingModels
import CommonUI
import Foundation
public import SwiftUI

// MARK: - NearbyBuildingRowContent

/// Row content for nearby-building lists ("Nearest to you" and a building's "Nearby buildings"):
/// the usual building row, with the distance shown in front of the available-rooms count.
public struct NearbyBuildingRowContent: View {

  // MARK: Lifecycle

  public init(nearbyBuilding: NearbyBuilding) {
    self.nearbyBuilding = nearbyBuilding
  }

  // MARK: Public

  public var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: NearbyBuildingLayout.contentSpacing) {
        Text(building.name)
          .bold()
          .foregroundStyle(theme.label.primary)
          .lineLimit(1)
          .truncationMode(.tail)

        HStack(spacing: NearbyBuildingLayout.detailSpacing) {
          Text(nearbyBuilding.formattedDistance)
            .fontWeight(.semibold)
            .foregroundStyle(theme.accent.primary)
          Text("·")
          if let count = building.numberOfAvailableRooms {
            Text("^[\(count) room](inflect: true) available")
          } else {
            Text("Availability unknown")
          }
        }
        .lineLimit(1)
      }

      Spacer()

      if let overallRating = building.overallRating {
        Text(overallRating.formatted())
        Image(systemName: "star.fill")
          .foregroundStyle(theme.yellow)
          .padding(.trailing)
      }
      Image(systemName: "chevron.right")
    }
    .accessibilityElement(children: .combine)
  }

  // MARK: Internal

  let nearbyBuilding: NearbyBuilding

  // MARK: Private

  @Environment(Theme.self) private var theme

  private var building: Building {
    nearbyBuilding.building
  }
}

// MARK: - NearbyBuildingDistanceBadge

/// A small distance label laid over a building card's image.
struct NearbyBuildingDistanceBadge: View {

  // MARK: Internal

  let nearbyBuilding: NearbyBuilding

  var body: some View {
    Label(nearbyBuilding.formattedDistance, systemImage: "location.fill")
      .labelStyle(.titleAndIcon)
      .font(.caption.weight(.semibold))
      .foregroundStyle(theme.label.primary)
      .padding(.vertical, NearbyBuildingLayout.badgeVerticalPadding)
      .padding(.horizontal, NearbyBuildingLayout.badgeHorizontalPadding)
      .background(.thinMaterial, in: Capsule())
      .accessibilityLabel("\(nearbyBuilding.formattedDistance) away")
  }

  // MARK: Private

  @Environment(Theme.self) private var theme
}

// MARK: - Distance formatting

extension NearbyBuilding {
  /// The distance for display, e.g. "120 m" or "1.2 km", in the user's local units.
  var formattedDistance: String {
    Measurement(value: distanceInMetres, unit: UnitLength.meters)
      .formatted(.measurement(width: .abbreviated, usage: .road))
  }
}

// MARK: - NearbyBuildingLayout

enum NearbyBuildingLayout {
  static let badgeHorizontalPadding: CGFloat = 8
  static let badgeInset: CGFloat = 10
  static let badgeVerticalPadding: CGFloat = 4
  static let contentSpacing: CGFloat = 5
  static let detailSpacing: CGFloat = 4
}
