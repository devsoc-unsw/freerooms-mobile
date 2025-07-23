//
//  FreeroomsApp.swift
//  Freerooms
//
//  Created by Anh Nguyen on 1/4/2025.
//

import Buildings
import BuildingViews
import CommonUI
import SwiftUI
import Location

@main
struct FreeroomsApp: App {

  // MARK: Lifecycle
  @State var viewModel: BuildingViewModel

  init() {
    Theme.registerFont(named: .ttCommonsPro)
    setFontOnToolbars(.ttCommonsPro)
    _viewModel = .init(initialValue: makeLiveBuildingViewModel())
//    self.viewModel = State(wrappedValue: makeLiveBuildingViewModel())
  }

  // MARK: Internal

  var body: some Scene {
    WindowGroup {
      ContentView(viewModel: viewModel)
        .preferredColorScheme(.light)
        .environment(theme)
        .environment(\.font, Font.custom(.ttCommonsPro, size: 14))
    }
  }
  
  func makeLiveBuildingViewModel() -> BuildingViewModel {
        let locationManager = LiveLocationManager()
        let locationService = LocationService(locationManager: locationManager)

        let remoteBuildingLoader = LiveRemoteBuildingLoader(url: URL(string: "/api/buildings")!)
        let buildingLoader = LiveBuildingLoader(remoteBuildingLoader: remoteBuildingLoader)
        let buildingService = LiveBuildingService(buildingLoader: buildingLoader)

        let interactor = BuildingInteractor(buildingService: buildingService, locationService: locationService)

        return LiveBuildingViewModel(interactor: interactor)
    }

  // MARK: Private

  @State private var theme = Theme.light

}
