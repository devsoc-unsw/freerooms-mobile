//
//  FreeroomsApp.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import BuildingInteractors
import BuildingServices
import BuildingViewModels
import BuildingViews
import CommonUI
import Location
import SwiftUI

// MARK: - FreeroomsApp

@main
struct FreeroomsApp: App {

  // MARK: Lifecycle

  init() {
    Theme.registerFont(named: .ttCommonsPro)
    setFontOnToolbars(.ttCommonsPro)
  }

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      ContentView()
        .preferredColorScheme(.light)
        .environment(theme)
        .environment(\.font, Font.custom(.ttCommonsPro, size: 14))
        .environment(viewModel)
    }
  }

  static func makeLiveBuildingViewModel() -> LiveBuildingViewModel {
    let locationManager = LiveLocationManager()
    let locationService = LocationService(locationManager: locationManager)

    // TODO: Replace with actual API endpoint
    let remoteBuildingLoader = LiveRemoteBuildingLoader(url: URL(string: "/api/buildings")!)
    let buildingLoader = LiveBuildingLoader(remoteBuildingLoader: remoteBuildingLoader)
    let buildingService = LiveBuildingService(buildingLoader: buildingLoader)

    let interactor = BuildingInteractor(buildingService: buildingService, locationService: locationService)

    return LiveBuildingViewModel(interactor: interactor)
  }

  // MARK: Private

  @State private var viewModel = FreeroomsApp.makeLiveBuildingViewModel()

  @State private var theme = Theme.light

}
