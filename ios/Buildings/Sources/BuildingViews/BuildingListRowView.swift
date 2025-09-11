//
//  BuildingListView.swift
//  Buildings
//
//  Created by Anh Nguyen on 13/6/2025.
//

import BuildingModels
import BuildingViewModels
import CommonUI
import SwiftUI

// MARK: - BuildingListRowView

struct BuildingListRowView: View {
  private struct HeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(
      value _: inout CGFloat,
      nextValue _: () -> CGFloat)
    { }
  }

  @Environment(Theme.self) private var theme

  @Binding var path: NavigationPath
  @Binding var rowHeight: CGFloat?
  let building: Building
  let buildings: [Building]
  var index: Int {
    buildings.firstIndex(of: building)!
  }

  var body: some View {
    Button {
      path.append(building)
    } label: {
      HStack(spacing: 0) {
        BuildingImage[building.id]
          .resizable()
          .frame(width: rowHeight, height: rowHeight) // This image matches the height of the below HStack
          .clipShape(RoundedRectangle(cornerRadius: 5))
          .padding(.trailing)

        HStack(spacing: 0) {
          VStack(alignment: .leading) {
            Text(building.name)
              .bold()
              .foregroundStyle(theme.label.primary)
              .lineLimit(1)
              .truncationMode(.tail)

            // The `^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true)` handles plurals using "automatic grammar agreement", works for a couple languages
            Text("^[\(building.numberOfAvailableRooms ?? 0) room](inflect: true) available")
          }

          Spacer()

          if let rating = building.overallRating {
            Text("\(rating.formatted())")
            Image(systemName: "star.fill")
              .foregroundStyle(theme.yellow)
              .padding(.trailing)
          }

          Image(systemName: "chevron.right")
        }
        .background(GeometryReader { geometry in
          // In a background the GeometryReader expands to the bounds of the foreground view
          Color.clear.preference(
            key: HeightPreferenceKey.self, // This saves the height into the HeightPreferenceKey
            value: geometry.size.height)
        })
      }
      .foregroundStyle(theme.label.secondary) // Applies to everything in child views unless overridden
    }
    .listRowBackground(
      RoundedRectangle(cornerRadius: 10)
        .fill(.background)
        .strokeBorder(LinearGradient(
          colors: [
            theme.accent.primary.opacity(1 - Double(buildings.count - index) / Double(buildings.count * 2)),
            theme.accent.primary.opacity(1 - Double(buildings.count - index - 1) / Double(buildings.count * 2)),
          ],
          startPoint: .top,
          endPoint: .bottom))
        .padding(.top, building == buildings.first ? 0 : -10) // Hide the top padding on the row unless this is the first row
        .padding(
          .bottom,
          building == buildings.last ? 0 : -10) // Hide the bottom padding on the row unless this is the last row
    )
    .onPreferenceChange(HeightPreferenceKey.self) {
      rowHeight = $0 // This value comes from the HStack above
    }
  }
}

// MARK: - PreviewWrapper

struct PreviewWrapper: View {
  @State private var path = NavigationPath()
  @State private var rowHeight: CGFloat?

  var buildings: [Building] = [
    Building(name: "AGSM", id: "K-F8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
  ]

  var body: some View {
    List {
      BuildingListRowView(
        path: $path,
        rowHeight: $rowHeight,
        building: buildings[0],
        buildings: buildings)
    }
    .listStyle(.plain)
  }
}

#Preview {
  PreviewWrapper()
    .defaultTheme()
}
