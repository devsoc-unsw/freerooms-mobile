//
//  NearbyBuildingViews.swift
//  Buildings
//
//  Created by Eric Wong on 13/11/2026.
//

public import BuildingModels
import CommonUI
public import SwiftUI

// MARK: - NearbyBuildingRowContent

/// Row content for a building screen's "Nearby buildings" list:
/// the usual building row, with the distance shown in front of the available-rooms count.
struct NearbyBuildingRowContent: View {

  // MARK: Lifecycle

  init(nearbyBuilding: NearbyBuilding) {
    self.nearbyBuilding = nearbyBuilding
  }

  // MARK: Internal

  let nearbyBuilding: NearbyBuilding

  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: NearbyBuildingLayout.contentSpacing) {
        Text(building.name)
          .bold()
          .foregroundStyle(theme.label.primary)
          .lineLimit(1)
          .truncationMode(.tail)

        DistanceAndAvailableRooms(
          metres: nearbyBuilding.distanceInMetres,
          availableRooms: building.numberOfAvailableRooms)
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

// MARK: - NearbyBuildingLayout

enum NearbyBuildingLayout {
  static let contentSpacing: CGFloat = 5
  static let listRowVerticalPadding: CGFloat = 5
}
