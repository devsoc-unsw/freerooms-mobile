//
//  MapTabView.swift
//  Freerooms
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 24/4/25.
//

import BottomSheet
import BuildingModels
import BuildingViewModels
import CommonUI
import MapKit
import RoomModels
import SwiftUI

extension View {
  func hideKeyboard() {
    // Dismiss keyboard - this will automatically unfocus
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil, from: nil, for: nil)
  }
}

// MARK: - MapTabView

public struct MapTabView<RoomDestination: View>: View {

  // MARK: Lifecycle

  public init(
    mapViewModel: LiveMapViewModel,
    roomImageProvider: @escaping (String) -> CachedImage,
    roomDestinationBuilder: @escaping (Room) -> RoomDestination)
  {
    self.mapViewModel = mapViewModel
    self.roomImageProvider = roomImageProvider
    self.roomDestinationBuilder = roomDestinationBuilder
  }

  // MARK: Public

  public var body: some View {
    ZStack {
      Map(position: $mapViewModel.position, bounds: mapViewModel.mapCameraBounds) {
        UserAnnotation {
          ZStack {
            CompassUserAnnotation()
              .environment(mapViewModel)
          }
        }

        // if currentRoute exist show route
        if let route = mapViewModel.currentRoute {
          let coordinates = route.polyline.coordinates
          MapPolyline(coordinates: coordinates)
            .stroke(
              .orange,
              style: StrokeStyle(
                lineWidth: 5))
        }

        ForEach(mapViewModel.buildings, id: \.id) { building in
          Annotation(building.name, coordinate: building.coordinate) {
            BuildingAnnotationView(
              building: building,
              isSelected: mapViewModel.isSelectedBuilding(building.id))
              .onTapGesture {
                  Task {
                      await mapViewModel.onSelectBuilding(building.id)
                  }
              }
          }
        }
      }
      .onChange(of: mapViewModel.selectedBuildingID) { _, _ in
        // This onChange forces view updates without needing visible UI
      }
      .onMapCameraChange { context in
        mapViewModel.updateMapHeading(context.camera.heading)
      }
      .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
      .mapControls {
        // Specifying no map controls removes the compass
      }
      // when user taps outside of the sheet, it shrinks down to medium size
      .simultaneousGesture(
          TapGesture()
              .onEnded {
                  if mapViewModel.bottomSheetPosition == SheetPosition.top.bottomSheetPosition {
                      withAnimation(.spring()) {
                          mapViewModel.bottomSheetPosition = SheetPosition.medium.bottomSheetPosition
                      }
                  }
              }
      )
      .bottomSheet(
        bottomSheetPosition: $mapViewModel.bottomSheetPosition,
        switchablePositions: [SheetPosition.top.bottomSheetPosition,   SheetPosition.medium.bottomSheetPosition, SheetPosition.short.bottomSheetPosition])
      {
        VStack {
          if mapViewModel.bottomSheetPosition == SheetPosition.short.bottomSheetPosition {
            SheetDirectionDetails()
          } else {
            SheetBuildingDetails(
              imageProvider: roomImageProvider,
              roomDestinationBuilder: roomDestinationBuilder)
          }
        }
      }
      .customBackground(
        Color(uiColor: .systemBackground)
          .cornerRadius(20)
          .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5))
      .onChange(of: mapViewModel.bottomSheetPosition) { _, newValue in
        if newValue == SheetPosition.medium.bottomSheetPosition {
          mapViewModel.clearDirection()
        } else if newValue == SheetPosition.short.bottomSheetPosition {
          Task {
            await mapViewModel.getDirectionToSelectedBuilding()
          }
        }
      }
      .task {
        mapViewModel.requestLocationPermission()
        await mapViewModel.loadBuildings()
      }
      .zIndex(0)
      VStack(spacing: 0) {
        MapSearchBar(searchtxt: $mapViewModel.searchText)
          .padding(.bottom, 6)
        if !mapViewModel.searchText.isEmpty {
          MapSearchBarList()
        }
        Spacer()
      }
      // search button is gone when sheet is at top
      .opacity(mapViewModel.bottomSheetPosition == SheetPosition.top.bottomSheetPosition ? 0 : 1)
      .animation(.easeInOut(duration: 0.3), value: mapViewModel.bottomSheetPosition)
    }
    .environment(mapViewModel)
    .ignoresSafeArea(.keyboard)
    .tabItem {
      Label("Map", systemImage: "map")
    }
    .tag("Map")
  }

  // MARK: Internal

  @Bindable var mapViewModel: LiveMapViewModel

  let roomImageProvider: (String) -> CachedImage
  let roomDestinationBuilder: (Room) -> RoomDestination
}

// MARK: - Preview

#Preview {
  MapTabView(
    mapViewModel: PreviewMapViewModel(),
    roomImageProvider: { roomID in
      CachedImage(name: roomID, bundle: .module)
    },
    roomDestinationBuilder: { _ in
      EmptyView()
    })
}
