//
//  MapView.swift
//  Freerooms
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 24/4/25.
//

import BuildingInteractors
import BuildingModels
import BuildingServices
import BuildingViewModels
import MapKit
import SwiftUI

// MARK: - MapTabView

public struct MapTabView: View {

  // MARK: Lifecycle

  public init(mapViewModel: LiveMapViewModel) {
    self.mapViewModel = mapViewModel
  }

  // MARK: Public

  public var body: some View {
    ZStack {
      Map(position: $mapViewModel.position, bounds: mapViewModel.mapCameraBounds) {
        UserAnnotation()

        // if currentRoute exist show route
        if let route = mapViewModel.currentRoute {
          let coordinates = route.polyline.coordinates
          MapPolyline(coordinates: coordinates)
            .stroke(
              .blue,
              style: StrokeStyle(
                lineWidth: 3,
                dash: [2, 2]))
        }

        ForEach(mapViewModel.buildings, id: \.id) { building in
          Annotation(building.name, coordinate: building.coordinate) {
            ZStack {
              // Your custom annotation view
              BuildingAnnotationView(
                building: building,
                isSelected: mapViewModel.isSelectedBuilding(building.id))
                .onTapGesture {
                  Task {
                    await mapViewModel.selectBuilding(building.id)
                  }
                }
            }
          }
        }
      }
      .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
      // ###########################################################################
      .safeAreaInset(edge: .bottom) {
        HStack {
          Text(mapViewModel.selectedBuildingName)

          if mapViewModel.selectedBuildingCoordinate != nil {
            if let scene = mapViewModel.lookAroundScene {
              Button(mapViewModel.currentRoute != nil ? "clear route" : "Get Directions") {
                Task {
                  if mapViewModel.currentRoute != nil {
                    mapViewModel.clearDirection()
                  } else {
                    await mapViewModel.getDirectionToSelectedBuilding()
                  }
                }
              }
              LookAroundPreview(initialScene: scene, allowsNavigation: true, showsRoadLabels: true)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(width: 150, height: 100)
                .padding()
              if mapViewModel.currentRoute != nil {
                Text(mapViewModel.currentRouteETA.detailedWalkingTime)
              }
            } else if mapViewModel.isLoadingLookAround == true {
              Text("Loading look around")
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(width: 150, height: 150)
                .padding()
            } else {
              Text("Here")
            }
          }
        }
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
      }
      // ###########################################################################
      .mapControls {
        MapCompass()
      }
      .task {
        await mapViewModel.loadBuildings()
      }
      .tabItem {
        Label("Map", systemImage: "map")
      }
      .tag("Map")
      // MARK: - Search Overlay Layer
      VStack(spacing: 0) {
        // MARK: Search Bar Container
        VStack(spacing: 0) {
          HStack(spacing: 12) {
            // Search TextField
            HStack {
              Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 16))

              TextField("Search buildings...", text: $mapViewModel.searchText)
                .focused($isSearchFocused)
                .onTapGesture {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    isSearching = true
                  }
                }
                .onChange(of: mapViewModel.searchText) { _, newValue in
                  if !newValue.isEmpty, !isSearching {
                    withAnimation(.easeInOut(duration: 0.2)) {
                      isSearching = true
                    }
                  }
                }

              // Clear button
              if !mapViewModel.searchText.isEmpty {
                Button(action: {
                  mapViewModel.searchText = ""
                }) {
                  Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                }
                .transition(.opacity)
              }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.regularMaterial)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

            // Cancel button (appears when searching)
            if isSearching {
              Button("Cancel") {
                dismissSearch()
              }
              .font(.system(size: 16, weight: .medium))
              .foregroundColor(.blue)
              .transition(.move(edge: .trailing).combined(with: .opacity))
            }
          }
          .padding(.horizontal, 16)
          .padding(.top, 8)
          .background(.regularMaterial)

          // MARK: Search Results Dropdown
          if isSearching, !mapViewModel.searchText.isEmpty {
            let filteredBuildings = mapViewModel.buildings.filter { building in
              building.name.lowercased().contains(mapViewModel.searchText.lowercased())
            }

            if !filteredBuildings.isEmpty {
              ScrollView {
                LazyVStack(spacing: 0) {
                  ForEach(filteredBuildings) { building in
                    SearchResultRow(
                      building: building,
                      searchText: mapViewModel.searchText,
                      isSelected: mapViewModel.isSelectedBuilding(building.id))
                    {
                      selectBuilding(building)
                    }

                    // Divider between items
                    if building.id != filteredBuildings.last?.id {
                      Divider()
                        .padding(.leading, 16)
                    }
                  }
                }
              }
              .frame(maxHeight: 250)
              .background(.regularMaterial)
              .clipShape(RoundedRectangle(cornerRadius: 12))
              .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
              .padding(.horizontal, 16)
              .padding(.bottom, 8)
              .transition(.move(edge: .top).combined(with: .opacity))
            } else {
              // No results found
              VStack {
                Image(systemName: "magnifyingglass")
                  .font(.largeTitle)
                  .foregroundColor(.gray)
                  .padding(.bottom, 4)

                Text("No buildings found")
                  .font(.headline)
                  .foregroundColor(.primary)

                Text("Try a different search term")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              .frame(height: 120)
              .frame(maxWidth: .infinity)
              .background(.regularMaterial)
              .clipShape(RoundedRectangle(cornerRadius: 12))
              .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
              .padding(.horizontal, 16)
              .padding(.bottom, 8)
              .transition(.move(edge: .top).combined(with: .opacity))
            }
          }
        }
        .animation(.easeInOut(duration: 0.25), value: isSearching)
        .animation(.easeInOut(duration: 0.25), value: mapViewModel.searchText.isEmpty)

        Spacer() // Push search to top
      }
    }
  }

  // MARK: Internal

  @Bindable var mapViewModel: LiveMapViewModel

  // MARK: Private

  @State private var isSearching = false
  @FocusState private var isSearchFocused: Bool

  private func selectBuilding(_ building: Building) {
    Task {
      await mapViewModel.selectBuilding(building.id)
      dismissSearch()
    }
  }

  private func dismissSearch() {
    withAnimation(.easeInOut(duration: 0.2)) {
      isSearching = false
      isSearchFocused = false
      mapViewModel.searchText = ""
    }
    hideKeyboard()
  }

  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

// MARK: - SearchResultRow

struct SearchResultRow: View {

  // MARK: Internal

  let building: Building
  let searchText: String
  let isSelected: Bool
  let onTap: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      // Building icon
      ZStack {
        Circle()
          .fill(building.availabilityColor.opacity(0.2))
          .frame(width: 32, height: 32)

        Circle()
          .fill(building.availabilityColor)
          .frame(width: 8, height: 8)
      }

      // Building info
      VStack(alignment: .leading, spacing: 2) {
        // Highlighted building name
        Text(highlightedText(building.name, searchText: searchText))
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.primary)

        // Additional info (you can customize this)
        Text("Building") // Or building.description if available
          .font(.system(size: 14))
          .foregroundColor(.secondary)
      }

      Spacer()

      // Selected indicator
      if isSelected {
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.blue)
          .font(.system(size: 18))
      } else {
        Image(systemName: "arrow.up.right")
          .foregroundColor(.gray)
          .font(.system(size: 14))
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .contentShape(Rectangle())
    .onTapGesture {
      onTap()
    }
  }

  // MARK: Private

  /// Helper to highlight search text
  private func highlightedText(_ text: String, searchText: String) -> AttributedString {
    var attributedString = AttributedString(text)

    if !searchText.isEmpty {
      let range = text.lowercased().range(of: searchText.lowercased())
      if let range {
        let nsRange = NSRange(range, in: text)
        if let attributedRange = Range<AttributedString.Index>(nsRange, in: attributedString) {
          attributedString[attributedRange].backgroundColor = .yellow.opacity(0.3)
          attributedString[attributedRange].foregroundColor = .primary
        }
      }
    }

    return attributedString
  }
}

// MARK: - Preview
#Preview {
  MapTabView(mapViewModel: PreviewMapViewModel())
}
