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
public import Location
public import Observation
public import RoomModels

// MARK: - BuildingViewModel

@MainActor
public protocol BuildingViewModel: Observable {
  var buildings: CampusBuildings { get }
  var filteredBuildings: CampusBuildings { get }
  var displayedBuildings: CampusBuildings { get }
  var allBuildings: [Building] { get }
  var sortOptions: Building.SortOptions { get set }
  var nearbyBuildingsByBuildingID: [String: [NearbyBuilding]] { get }
  var isLoading: Bool { get }
  var hasLoaded: Bool { get }
  var loadBuildingErrorMessage: AlertError? { get set }
  var searchText: String { get set }
  var placeHolderBuildings: CampusBuildings { get }

  func getBuildingsInOrder()
  func sort(by kind: Building.SortOptions.Kind, near userLocation: Location?)
  func updateNearestSort(near userLocation: Location?)
  func onAppear()
  func loadBuildings() async
  func reloadBuildings() async
  func loadNearbyBuildings(to building: Building) async
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
  public var sortOptions = Building.SortOptions.alphabetical
  public var isLoading = false
  public var searchText = ""
  public var nearbyBuildingsByBuildingID: [String: [NearbyBuilding]] = [:]
  public var loadBuildingErrorMessage: AlertError?

  public private(set) var buildings: CampusBuildings = ([], [], [])

  /// Every building, A–Z, whatever the tab's sort. Worked out once per load.
  public private(set) var allBuildings: [Building] = []

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
      await loadBuildings()
    }
  }

  public func onAppear() {
    // Load buildings once when the view appears
    Task {
      await loadBuildings()
    }

    hasLoaded = true
  }

  public func loadBuildings() async {
    isLoading = true

    switch await interactor.getBuildings() {
    case .success(let fetchedBuildings):
      store(fetchedBuildings)
      // Sorts after the fetch, so a sort picked while it was loading still applies.
      applySortOptions()

    case .failure(let error):
      loadBuildingErrorMessage = AlertError(message: error.clientMessage)
    }

    isLoading = false
  }

  /// Sorts by the kind the user picked, keeping Reverse as it is. Does nothing for nearest
  /// without a location.
  public func sort(by kind: Building.SortOptions.Kind, near userLocation: Location?) {
    guard apply(kind, near: userLocation) else { return }
    prefersNearestSort = kind == .nearest
  }

  /// While the user wants Distance, re-sorts from `userLocation` so the order follows them.
  /// Without a location it shows A–Z, and goes back to Distance when the location returns, as
  /// the Rooms tab does.
  public func updateNearestSort(near userLocation: Location?) {
    guard prefersNearestSort else { return }
    apply(userLocation == nil ? .alphabetical : .nearest, near: userLocation)
  }

  public func getBuildingsInOrder() {
    guard !isLoading else { return }
    isLoading = true
    sortOptions.reverse()
    applySortOptions()
    isLoading = false
  }

  /// Loads the buildings closest to `building`, nearest first, stored under its ID so each
  /// building screen keeps its own list. Stores an empty list on failure, hiding the section.
  public func loadNearbyBuildings(to building: Building) async {
    switch await interactor.getBuildingsNearest(from: building, limit: Self.nearbyBuildingsLimit) {
    case .success(let nearby):
      nearbyBuildingsByBuildingID[building.id] = nearby
    case .failure:
      nearbyBuildingsByBuildingID[building.id] = []
    }
  }

  // MARK: Private

  /// How many buildings a building screen's "Nearby buildings" section shows
  private static let nearbyBuildingsLimit = 3

  private var interactor: BuildingInteractor

  /// Whether the user picked Distance, which stays true while there's no location to sort by.
  private var prefersNearestSort = false

  /// Stores fetched buildings split by campus, and every building A–Z.
  private func store(_ fetchedBuildings: [Building]) {
    buildings.upper = interactor.getBuildingsFilteredByCampusSection(buildings: fetchedBuildings, .upper)
    buildings.middle = interactor.getBuildingsFilteredByCampusSection(buildings: fetchedBuildings, .middle)
    buildings.lower = interactor.getBuildingsFilteredByCampusSection(buildings: fetchedBuildings, .lower)
    allBuildings = Building.SortOptions.alphabetical.sort(fetchedBuildings)
  }

  /// Switches to `kind` and re-sorts. Returns `false`, changing nothing, for nearest without a
  /// location.
  @discardableResult
  private func apply(_ kind: Building.SortOptions.Kind, near userLocation: Location?) -> Bool {
    guard
      let newSortOptions = Building.SortOptions.sorting(
        by: kind,
        isAscending: sortOptions.isAscending,
        near: userLocation?.coordinate)
    else { return false }
    sortOptions = newSortOptions
    applySortOptions()
    return true
  }

  /// Re-sorts the buildings already loaded, without fetching them again.
  private func applySortOptions() {
    buildings.upper = sortOptions.sort(buildings.upper)
    buildings.middle = sortOptions.sort(buildings.middle)
    buildings.lower = sortOptions.sort(buildings.lower)
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
