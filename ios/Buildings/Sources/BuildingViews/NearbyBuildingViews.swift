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
          // The location arrow marks this as a distance, so "80 m" isn't read as minutes.
          // A plain HStack rather than a Label, whose icon-to-title gap is too wide here.
          HStack(spacing: NearbyBuildingLayout.distanceIconSpacing) {
            Image(systemName: "location.fill")
              .imageScale(.small)
              .accessibilityHidden(true)
            Text(nearbyBuilding.formattedDistance)
          }
          .fontWeight(.semibold)
          .foregroundStyle(theme.accent.primary)
          if let count = building.numberOfAvailableRooms {
            Text("·")
            // Uses the first one that fits: two-digit counts don't fit in full next to the distance.
            ViewThatFits(in: .horizontal) {
              Text("^[\(count) room](inflect: true) available")
              Text("\(count) available")
            }
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

// MARK: - NearbyBuildingsSection

/// The "Nearby buildings" section at the bottom of a building's screen. Shows nothing when
/// the list is empty. Tapping a building pushes it onto `path`.
public struct NearbyBuildingsSection: View {

  // MARK: Lifecycle

  public init(nearbyBuildings: [NearbyBuilding], path: Binding<NavigationPath>) {
    self.nearbyBuildings = nearbyBuildings
    _path = path
  }

  // MARK: Public

  public var body: some View {
    if !nearbyBuildings.isEmpty {
      Section {
        ForEach(nearbyBuildings) { nearbyBuilding in
          GenericListRowView(
            rowHeight: $rowHeight,
            item: nearbyBuilding,
            items: nearbyBuildings,
            isLoading: false,
            onSelect: { path.append($0.building) },
            imageProvider: { buildingID in
              BuildingImage[buildingID]
            },
            content: { nearbyBuilding in
              NearbyBuildingRowContent(nearbyBuilding: nearbyBuilding)
            })
            .padding(.vertical, NearbyBuildingLayout.listRowVerticalPadding)
        }
      } header: {
        Text("Nearby buildings")
          .textCase(.uppercase)
          .foregroundStyle(theme.label.primary)
      }
    }
  }

  // MARK: Internal

  @Binding var path: NavigationPath
  @State var rowHeight: CGFloat?

  let nearbyBuildings: [NearbyBuilding]

  // MARK: Private

  @Environment(Theme.self) private var theme
}

// MARK: - NearbyBuildingDistanceBadge

/// A small distance label laid over a building card's image.
struct NearbyBuildingDistanceBadge: View {

  // MARK: Internal

  let nearbyBuilding: NearbyBuilding

  var body: some View {
    Label("\(nearbyBuilding.formattedDistance) away", systemImage: "location.fill")
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
  static let distanceIconSpacing: CGFloat = 3
  static let listRowVerticalPadding: CGFloat = 5
}
