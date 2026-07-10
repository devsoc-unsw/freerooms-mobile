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
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil,
      from: nil,
      for: nil)
  }
}

// MARK: - MapTabView

public struct MapTabView<RoomDestination: View>: View {

  // MARK: Lifecycle

  public init(
    path: Binding<NavigationPath>,
    mapViewModel: LiveMapViewModel,
    roomImageProvider: @escaping (String) -> CachedImage,
    roomDestinationBuilder: @escaping (Room) -> RoomDestination)
  {
    self.mapViewModel = mapViewModel
    self.roomImageProvider = roomImageProvider
    self.roomDestinationBuilder = roomDestinationBuilder
    _path = path
  }

  // MARK: Public

  public var body: some View {
    NavigationStack(path: $path) {
      ZStack {
        Map(
          position: $mapViewModel.position,
          bounds: mapViewModel.mapCameraBounds)
        {
          UserAnnotation {
            ZStack {
              CompassUserAnnotation()
                .environment(mapViewModel)
            }
          }

          if let route = mapViewModel.currentRoute {
            let coordinates = route.polyline.coordinates
            MapPolyline(coordinates: coordinates)
              .stroke(
                .orange,
                style: StrokeStyle(
                  lineWidth: MapLayoutConstants.routeLineWidth))
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
        .onChange(of: mapViewModel.selectedBuildingID) { _, _ in }
        .onMapCameraChange { context in
          mapViewModel.updateMapHeading(context.camera.heading)
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .mapControls { }
        .simultaneousGesture(
          TapGesture()
            .onEnded {
              if
                mapViewModel.bottomSheetPosition
                == SheetPosition.top.bottomSheetPosition
              {
                withAnimation(.spring()) {
                  mapViewModel.bottomSheetPosition =
                    SheetPosition.medium.bottomSheetPosition
                }
              }
            })
        .task {
          mapViewModel.requestLocationPermission()
          await mapViewModel.loadBuildings()
        }
        .zIndex(0)

        VStack(spacing: 0) {
          MapSearchBar(searchtxt: $mapViewModel.searchText)
            .padding(.bottom, MapLayoutConstants.searchBarBottomPadding)
          if !mapViewModel.searchText.isEmpty {
            MapSearchBarList()
          }
          Spacer()
        }
        .opacity(
          mapViewModel.bottomSheetPosition
            == SheetPosition.top.bottomSheetPosition
            ? MapLayoutConstants.searchOverlayHiddenOpacity
            : MapLayoutConstants.searchOverlayVisibleOpacity)
          .animation(
            .easeInOut(duration: MapLayoutConstants.searchOverlayAnimationDuration),
            value: mapViewModel.bottomSheetPosition)
      }
      .bottomSheet(
        bottomSheetPosition: $mapViewModel.bottomSheetPosition,
        switchablePositions: [
          SheetPosition.top.bottomSheetPosition,
          SheetPosition.medium.bottomSheetPosition,
          SheetPosition.short.bottomSheetPosition,
        ]) {
          VStack {
            if
              mapViewModel.bottomSheetPosition
              == SheetPosition.short.bottomSheetPosition
            {
              SheetDirectionDetails()
            } else {
              SheetBuildingDetails(
                imageProvider: roomImageProvider,
                onSelectRoom: { room in
                  path.append(room)
                })
            }
          }
      }
      .customBackground(
        Color(uiColor: .systemBackground)
          .cornerRadius(MapLayoutConstants.sheetCornerRadius)
          .shadow(
            color: .black.opacity(MapLayoutConstants.sheetShadowOpacity),
            radius: MapLayoutConstants.sheetShadowRadius,
            x: MapLayoutConstants.sheetShadowXOffset,
            y: MapLayoutConstants.sheetShadowYOffset))
      .onChange(of: mapViewModel.bottomSheetPosition) { _, newValue in
        if newValue == SheetPosition.medium.bottomSheetPosition {
          mapViewModel.clearDirection()
        } else if newValue == SheetPosition.short.bottomSheetPosition {
          Task {
            await mapViewModel.getDirectionToSelectedBuilding()
          }
        }
      }
      .environment(mapViewModel)
      .ignoresSafeArea(.keyboard)
      .navigationDestination(for: Room.self) { room in
        roomDestinationBuilder(room)
      }
    }
    .tabItem {
      Label("Map", systemImage: "map")
    }
    .tag("Map")
  }

  // MARK: Internal

  @Bindable var mapViewModel: LiveMapViewModel
  @Binding var path: NavigationPath

  let roomImageProvider: (String) -> CachedImage
  let roomDestinationBuilder: (Room) -> RoomDestination

}

// MARK: - PreviewWrapper

private struct PreviewWrapper: View {
  @State var path = NavigationPath()

  var body: some View {
    MapTabView(
      path: $path,
      mapViewModel: PreviewMapViewModel(),
      roomImageProvider: { roomID in
        CachedImage(name: roomID, bundle: .module)
      },
      roomDestinationBuilder: { _ in
        EmptyView()
      })
  }
}

// MARK: - Preview

#Preview {
  PreviewWrapper()
}
