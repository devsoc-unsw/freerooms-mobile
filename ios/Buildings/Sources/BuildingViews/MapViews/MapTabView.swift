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

extension View {
  func hideKeyboard() {
    // Dismiss keyboard - this will automatically unfocus
    UIApplication.shared.sendAction(
      #selector(UIResponder.resignFirstResponder),
      to: nil, from: nil, for: nil)
  }
}

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
        UserAnnotation {
          ZStack {
            CompassUserAnnotation(mapViewModel: mapViewModel)
          }
        }

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
          Text("\(mapViewModel.selectedBuildingAvailableRooms)")
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
      .task {
        await mapViewModel.loadBuildings()
      }
      VStack {
        MapSearchBar(searchtxt: $mapViewModel.searchText)
        if !mapViewModel.searchText.isEmpty {
          List(mapViewModel.filteredBuildings, id: \.self) { building in
            Button {
              Task {
                await mapViewModel.selectBuilding(building.id)
                mapViewModel.focusBuildingOnMap()
              }
              mapViewModel.clearSearch()
              hideKeyboard()
            } label: {
              HStack {
                Circle()
                  .fill(building.availabilityColor)
                  .frame(
                    width: 16,
                    height: 16)
                  .overlay {
                    Circle()
                      .stroke(Color.white, lineWidth: 3)
                  }
                  .shadow(
                    color: .black.opacity(0.3),
                    radius: 2,
                    x: 0,
                    y: 1)
                Text(building.name)
                  .foregroundStyle(.black)
              }
            }
          }
          .frame(maxHeight: 300)
          .scrollContentBackground(.hidden)
        }
        Spacer()
      }
    }
    .ignoresSafeArea(.keyboard)
    .tabItem {
      Label("Map", systemImage: "map")
    }
    .tag("Map")
  }

  // MARK: Internal

  @Bindable var mapViewModel: LiveMapViewModel

}

// MARK: - Preview
#Preview {
  MapTabView(mapViewModel: PreviewMapViewModel())
}
