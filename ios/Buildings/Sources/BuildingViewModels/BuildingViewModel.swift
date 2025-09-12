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
  var buildings: CampusBuildings { get }
  var filteredBuildings: CampusBuildings { get }
  var allBuildings: [Building] { get }
  var buildingsInAscendingOrder: Bool { get }
  var isLoading: Bool { get }
  var searchText: String { get set }

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

  public var buildingsInAscendingOrder = true
  public var isLoading = false
  public var searchText = ""

  public var buildings: CampusBuildings = ([], [], [])

  public var filteredBuildings: CampusBuildings {
    interactor.filterBuildingsByQueryString(buildings, by: searchText)
  }

  public var allBuildings: [Building] {
    let allBuildings = buildings.0 + buildings.1 + buildings.2
    return interactor.getBuildingsSortedAlphabetically(buildings: allBuildings, order: true)
  }

  public func getLoadingStatus() -> Bool {
    isLoading
  }

  public func onAppear() {
    // Load buildings once when the view appears
    guard !hasLoaded else { return }
    hasLoaded = true
    Task {
      await loadBuildings()
    }
  }

  public func loadBuildings() async {
    // Prevent re-entrancy
    guard !isLoading else { return }
    isLoading = true

    // Fetch all buildings once, then derive sections in-memory
    let buildingResult = await interactor.getBuildingsSortedAlphabetically(inAscendingOrder: true)

    switch buildingResult {
    case .success(let fetchedBuildings):
      let uniqueBuildings = uniqueById(fetchedBuildings)

      let upper = interactor.getBuildingsFilteredByCampusSection(buildings: uniqueBuildings, .upper)
      let middle = interactor.getBuildingsFilteredByCampusSection(buildings: uniqueBuildings, .middle)
      let lower = interactor.getBuildingsFilteredByCampusSection(buildings: uniqueBuildings, .lower)

      buildings.upper = interactor.getBuildingsSortedAlphabetically(
        buildings: upper,
        order: buildingsInAscendingOrder)
      buildings.middle = interactor.getBuildingsSortedAlphabetically(
        buildings: middle,
        order: buildingsInAscendingOrder)
      buildings.lower = interactor.getBuildingsSortedAlphabetically(
        buildings: lower,
        order: buildingsInAscendingOrder)

    case .failure(let error):
      // swiftlint:disable:next no_direct_standard_out_logs
      print("Error loading buildings: \(error)")
    }

    isLoading = false
  }

  public func getBuildingsInOrder() {
    guard !isLoading else { return }
    isLoading = true
    buildingsInAscendingOrder.toggle()

    buildings.upper = interactor.getBuildingsSortedAlphabetically(
      buildings: buildings.upper,
      order: buildingsInAscendingOrder)
    buildings.lower = interactor.getBuildingsSortedAlphabetically(
      buildings: buildings.lower,
      order: buildingsInAscendingOrder)
    buildings.middle = interactor.getBuildingsSortedAlphabetically(
      buildings: buildings.middle,
      order: buildingsInAscendingOrder)

    isLoading = false
  }

  // MARK: Private

  private var hasLoaded = false
  private var interactor: BuildingInteractor

  private func uniqueById(_ input: [Building]) -> [Building] {
    var seen = Set<String>()
    return input.filter { seen.insert($0.id).inserted }
  }
}

// MARK: - PreviewBuildingViewModel

@Observable
// swiftlint:disable:next no_unchecked_sendable
public class PreviewBuildingViewModel: LiveBuildingViewModel, @unchecked Sendable {

  public init() {
    super.init(interactor: BuildingInteractor(
      buildingService: PreviewBuildingService(),
      locationService: LiveLocationService(locationManager: LiveLocationManager())))
  }
}
