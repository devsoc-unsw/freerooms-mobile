//
//  BuildingViewModel.swift
//  Buildings
//
//  Created by Yanlin Li  on 3/7/2025.
//

public import BuildingInteractors
public import BuildingModels
import BuildingServices
import Foundation
import Location
public import Observation
public import RoomModels

// MARK: - BuildingViewModel

@MainActor
public protocol BuildingViewModel {
  var buildings: CampusBuildings { get }
  var filteredBuildings: CampusBuildings { get }
  var displayedBuildings: CampusBuildings { get }
  var allBuildings: [Building] { get }
  var nearestBuildings: [NearbyBuilding] { get }
  var buildingsInAscendingOrder: Bool { get }
  var isLoading: Bool { get }
  var hasLoaded: Bool { get }
  var loadBuildingErrorMessage: AlertError? { get set }
  var searchText: String { get set }
  var placeHolderBuildings: CampusBuildings { get }

  func getBuildingsInOrder()
  func onAppear()
  func loadBuildings() async
  func reloadBuildings() async
  func loadNearestBuildings() async
}

// MARK: - LiveBuildingViewModel

@Observable
public class LiveBuildingViewModel: BuildingViewModel {

  // MARK: Lifecycle

  public init(interactor: BuildingInteractor) {
    self.interactor = interactor
  }

  // MARK: Public

  public var hasLoaded = false
  public var buildingsInAscendingOrder = true
  public var isLoading = false
  public var searchText = ""
  public var nearestBuildings: [NearbyBuilding] = []
  public var loadBuildingErrorMessage: AlertError?
  public var selectedFilter = BuildingFilterOptions.Alphabetical

  public var buildings: CampusBuildings = ([], [], [])

  public var displayedBuildings: CampusBuildings {
    let isEmpty = buildings.upper.isEmpty && buildings.middle.isEmpty && buildings.lower.isEmpty

    if isLoading, isEmpty {
      return placeHolderBuildings
    }

    return filteredBuildings
  }

  public var filteredBuildings: CampusBuildings {
    interactor.filterBuildingsByQueryString(buildings, by: searchText)
  }

  public var allBuildings: [Building] {
    let allBuildings = buildings.0 + buildings.1 + buildings.2
    return interactor.getBuildingsSortedAlphabetically(buildings: allBuildings, order: true)
  }

  public var placeHolderBuildings: CampusBuildings {
    let createPlaceholder: (Int) -> Building = { index in
      Building(
        name: "Loading Building Name",
        id: "placeholder-\(index)",
        latitude: 0.0,
        longitude: 0.0,
        aliases: ["LBN"],
        numberOfAvailableRooms: 5,
        overallRating: 4.5)
    }

    // Create 2 placeholders for each section (6 total)
    let upperPlaceholders = (0..<6).map(createPlaceholder)
    let middlePlaceholders = (2..<12).map(createPlaceholder)
    let lowerPlaceholders = (4..<18).map(createPlaceholder)

    return (upper: upperPlaceholders, middle: middlePlaceholders, lower: lowerPlaceholders)
  }

  public func reloadBuildings() {
    Task {
      isLoading = true
      let buildingResult: Result<[Building], FetchBuildingsError>

      switch selectedFilter {
      case .Alphabetical:
        buildingResult = await interactor.getBuildingsSortedAlphabetically(inAscendingOrder: buildingsInAscendingOrder)
      case .Location:
        // Not Implemented
        fatalError("Unreachable")
      case .CampusSection:
        // Not Implemented
        fatalError("Unreachable")
      }

      // Fetch buildings with the determined sort order

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
        loadBuildingErrorMessage = AlertError(message: error.clientMessage)
      }

      isLoading = false

      await loadNearestBuildings()
    }
  }

  public func getLoadingStatus() -> Bool {
    isLoading
  }

  public func onAppear() {
    // Ask for location up front so the "Nearest to you" section can appear. A denied
    // permission isn't an error here: the section just stays hidden.
    _ = try? interactor.requestLocationPermission()

    // Load buildings once when the view appears
    Task {
      await loadBuildings()
      await loadNearestBuildings()
    }

    hasLoaded = true
  }

  public func loadBuildings() async {
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
      loadBuildingErrorMessage = AlertError(message: error.clientMessage)
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

  /// Loads the buildings closest to the user. Clears the list (hiding the section) when
  /// there's no location permission or GPS fix yet, rather than showing an error.
  public func loadNearestBuildings() async {
    switch await interactor.getNearestBuildings(limit: Self.nearestBuildingsLimit) {
    case .success(let nearest):
      nearestBuildings = nearest
    case .failure:
      nearestBuildings = []
    }
  }

  // MARK: Private

  /// How many buildings the "Nearest to you" section shows.
  private static let nearestBuildingsLimit = 4

  private var interactor: BuildingInteractor

  private func uniqueById(_ input: [Building]) -> [Building] {
    var seen = Set<String>()
    return input.filter { seen.insert($0.id).inserted }
  }
}

// MARK: - PreviewBuildingViewModel

@Observable
public class PreviewBuildingViewModel: LiveBuildingViewModel {

  public init() {
    super.init(interactor: BuildingInteractor(
      buildingService: PreviewBuildingService(),
      locationService: LiveLocationService(locationManager: LiveLocationManager())))
  }
}
