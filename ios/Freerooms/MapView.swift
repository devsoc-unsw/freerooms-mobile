//
//  MapView.swift
//  Freerooms
//
//  Created by MUQUEET MOHSEN CHOWDHURY on 24/4/25.
//

import Buildings
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
      let availableRooms = building.numberOfAvailableRooms ?? 0
      annotation.title = building.name
      annotation.subtitle = "\(availableRooms) rooms available"
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
    Building(name: "Quad", id: "quad", latitude: -33.9173, longitude: 151.2312, aliases: [], numberOfAvailableRooms: 3),
    Building(name: "SLT", id: "slt", latitude: -33.9195, longitude: 151.2245, aliases: [], numberOfAvailableRooms: 5),
  ])
  .ignoresSafeArea()
}
