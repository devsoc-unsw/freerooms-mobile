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

  var lowerCampusBuildings: [Building] { get }

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

  public var lowerCampusBuildings: [Building] = []

  public var middleCampusBuildings: [Building] = []

  public var buildingsInAscendingOrder = false

  public var isLoading = false

  public func getLoadingStatus() -> Bool {
    isLoading
  }

  public func onAppear() {
    // Load buildings when the view appears
    loadBuildings()
  }

  /// New method to load buildings asynchronously
  public func loadBuildings() {
    isLoading = true

    // Load all campus sections concurrently
    let upperResult = interactor.getBuildingsFilteredByCampusSection(.upper)
    let lowerResult = interactor.getBuildingsFilteredByCampusSection(.lower)
    let middleResult = interactor.getBuildingsFilteredByCampusSection(.middle)

    // Wait for all results
    let results = (upperResult, lowerResult, middleResult)

    switch results.0 {
    case .success(let buildings):
      upperCampusBuildings = sortBuildingsInOrder(buildings: buildings, order: buildingsInAscendingOrder)
    case .failure(let error):
      // swiftlint:disable:next no_direct_standard_out_logs
      print("Error loading upper campus buildings: \(error)")
    }

    switch results.1 {
    case .success(let buildings):
      lowerCampusBuildings = sortBuildingsInOrder(buildings: buildings, order: buildingsInAscendingOrder)
    case .failure(let error):
      // swiftlint:disable:next no_direct_standard_out_logs
      print("Error loading lower campus buildings: \(error)")
    }

    switch results.2 {
    case .success(let buildings):
      middleCampusBuildings = sortBuildingsInOrder(buildings: buildings, order: buildingsInAscendingOrder)
    case .failure(let error):
      // swiftlint:disable:next no_direct_standard_out_logs
      print("Error loading middle campus buildings: \(error)")
    }

    isLoading = false
  }

  public func getBuildingsInOrder() {
    isLoading = true
    buildingsInAscendingOrder.toggle()

    upperCampusBuildings = sortBuildingsInOrder(buildings: upperCampusBuildings, order: buildingsInAscendingOrder)
    lowerCampusBuildings = sortBuildingsInOrder(buildings: lowerCampusBuildings, order: buildingsInAscendingOrder)
    middleCampusBuildings = sortBuildingsInOrder(buildings: middleCampusBuildings, order: buildingsInAscendingOrder)

    // Simulate delay from fetching buildings
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }

      isLoading = false
    }
  }

  // MARK: Private

  private var interactor: BuildingInteractor

  private func sortBuildingsInOrder(buildings: [Building], order: Bool) -> [Building] {
    buildings.sorted { a, b in
      order ? a.name < b.name : a.name > b.name
    }
  }

}

// MARK: - PreviewBuildingViewModel

@Observable
// swiftlint:disable:next no_unchecked_sendable
public class PreviewBuildingViewModel: LiveBuildingViewModel, @unchecked Sendable {

  public init() {
    super.init(interactor: BuildingInteractor(
      buildingService: PreviewBuildingService(),
      locationService: LocationService(locationManager: LiveLocationManager())))
  }
}
