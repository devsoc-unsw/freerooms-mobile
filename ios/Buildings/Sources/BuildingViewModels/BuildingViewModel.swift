//
//  ViewModel.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

import BuildingInteractors
import BuildingModels
import BuildingServices
import Foundation
import Location
import Observation

// MARK: - BuildingViewModel

public protocol BuildingViewModel {
  var upperCampusBuildings: [Building] { get set }

  var middleCampusBuildings: [Building] { get }

  var buildingsInAscendingOrder: Bool { get }

  var isLoading: Bool { get }

  func getBuildingsInOrder()

  func onAppear()

}

// MARK: - LiveBuildingViewModel

@Observable
// swiftlint:disable:next no_unchecked_sendable
public class LiveBuildingViewModel: BuildingViewModel, @unchecked Sendable {

  // MARK: Lifecycle

  public init(interactor: BuildingInteractor) {
    self.interactor = interactor
  }

  // MARK: Public

  public var upperCampusBuildings: [Building] = []

  public var middleCampusBuildings: [Building] = []

  public var buildingsInAscendingOrder = true

  public var isLoading = false

  public func getLoadingStatus() -> Bool {
    isLoading
  }

  public func onAppear() { }

  public func getBuildingsInOrder() {
    isLoading = true
    buildingsInAscendingOrder.toggle()

    // Simulate delay from fetching buildings
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }

      isLoading = false
    }
  }

  // MARK: Internal

  var interactor: BuildingInteractor

}

// MARK: - PreviewBuildingViewModel

@Observable
// swiftlint:disable:next no_unchecked_sendable
public class PreviewBuildingViewModel: LiveBuildingViewModel, @unchecked Sendable {

  public init() {
    super.init(interactor: BuildingInteractor(
      buildingService: PreviewBuildingService(),
      locationService: LocationService(locationManager: LiveLocationManager())))
    upperCampusBuildings = [
      Building(name: "AGSM", id: "K-E4", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
      Building(name: "Biological Sciences", id: "K-E8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 2),
      Building(
        name: "Biological Sciences (West)",
        id: "K-E10",
        latitude: 0,
        longitude: 0,
        aliases: [],
        numberOfAvailableRooms: 3),
      Building(name: "Matthews Building", id: "K-E12", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 4),
    ]
    middleCampusBuildings = [
      Building(name: "AGSM", id: "K-F8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
      Building(name: "Biological Sciences", id: "K-F10", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 2),
      Building(
        name: "Biological Sciences (West)",
        id: "K-F12",
        latitude: 0,
        longitude: 0,
        aliases: [],
        numberOfAvailableRooms: 3),
      Building(name: "Matthews Building", id: "K-F13", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 4),
    ]
  }
}
