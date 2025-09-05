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
  var buildings: [Building] { get }

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

  public var buildings: [Building] = []

  public var upperCampusBuildings: [Building] = []

  public var lowerCampusBuildings: [Building] = []

  public var middleCampusBuildings: [Building] = []

  public var buildingsInAscendingOrder = true

  public var isLoading = false

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
      let unique = uniqueById(fetchedBuildings)
      buildings = unique

      let upper = interactor.getBuildingsFilteredByCampusSection(buildings: buildings, .upper)
      let middle = interactor.getBuildingsFilteredByCampusSection(buildings: buildings, .middle)
      let lower = interactor.getBuildingsFilteredByCampusSection(buildings: buildings, .lower)

      upperCampusBuildings = interactor.getBuildingsSortedAlphabetically(
        buildings: upper,
        order: buildingsInAscendingOrder)
      middleCampusBuildings = interactor.getBuildingsSortedAlphabetically(
        buildings: middle,
        order: buildingsInAscendingOrder)
      lowerCampusBuildings = interactor.getBuildingsSortedAlphabetically(
        buildings: lower,
        order: buildingsInAscendingOrder)

    case .failure(let error):
      // swiftlint:disable:next no_direct_standard_out_logs
      print("Error loading buildings: \(error)")

      buildings = []
      upperCampusBuildings = []
      middleCampusBuildings = []
      lowerCampusBuildings = []
    }

    isLoading = false
  }

  public func getBuildingsInOrder() {
    guard !isLoading else { return }
    isLoading = true
    buildingsInAscendingOrder.toggle()

    upperCampusBuildings = interactor.getBuildingsSortedAlphabetically(
      buildings: upperCampusBuildings,
      order: buildingsInAscendingOrder)
    lowerCampusBuildings = interactor.getBuildingsSortedAlphabetically(
      buildings: lowerCampusBuildings,
      order: buildingsInAscendingOrder)
    middleCampusBuildings = interactor.getBuildingsSortedAlphabetically(
      buildings: middleCampusBuildings,
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
