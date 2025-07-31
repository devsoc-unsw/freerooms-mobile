//
//  MapView.swift
//  Freerooms
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 24/4/25.
//

import BuildingModels
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
  let buildings: [Building]

  func makeUIView(context _: Context) -> MKMapView {
    MKMapView()
  }

  func updateUIView(_ uiView: MKMapView, context _: Context) {
    // Remove all existing pins before adding new ones
    uiView.removeAnnotations(uiView.annotations)

    // Turn each Building into a map annotation (pin)
    let annotations = buildings.map { building -> MKPointAnnotation in
      let annotation = MKPointAnnotation()
      annotation.title = building.name
      annotation.coordinate = CLLocationCoordinate2D(
        latitude: building.latitude,
        longitude: building.longitude)
      return annotation
    }

    // Zoom the map to show all pins
    uiView.showAnnotations(annotations, animated: true)
  }
}

// MARK: - Preview
#Preview {
  MapView(buildings: [
    Building(name: "Quad", id: "quad", latitude: -33.9173, longitude: 151.2312, aliases: []),
    Building(name: "SLT", id: "slt", latitude: -33.9195, longitude: 151.2245, aliases: []),
  ])
  .ignoresSafeArea()
}
