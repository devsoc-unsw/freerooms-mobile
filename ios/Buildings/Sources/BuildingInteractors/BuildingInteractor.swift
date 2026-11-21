//
//  BuildingInteractor.swift
//  Buildings
//
//  Created by Anh Nguyen on 27/4/2025.
//

public import BuildingModels
public import BuildingServices
import Foundation
public import Location
import RoomModels
import RoomServices

// MARK: - BuildingInteractor

/// Coordinates building-related operations including filtering, sorting, and room status integration.
/// Acts as the main interface between the presentation layer and building services.
public class BuildingInteractor {

  // MARK: Lifecycle

  /// Creates a new BuildingInteractor with the required services.
  /// - Parameters:
  ///   - buildingService: Service for building data operations
  ///   - locationService: Service for location-based operations
  public init(
    buildingService: any BuildingService,
    locationService: any LocationService)
  {
    self.buildingService = buildingService
    self.locationService = locationService
  }

  // MARK: Public

  public func getBuildingsFilteredByCampusSection(buildings: [Building], _ campusSection: CampusSection) -> [Building] {
    buildings.filter { $0.gridReference.campusSection == campusSection }
  }

  /// The user's current location, or `nil` without location permission or a GPS fix.
  public func getUserLocation() -> Location? {
    try? locationService.getCurrentLocation()
  }

  /// How far `origin` is from each building, in metres, keyed by building ID. Doesn't fetch or
  /// read the location: pass in the buildings the app already has and the user's location.
  public func getDistances(to buildings: [Building], from origin: Location) -> [String: Double] {
    Dictionary(
      buildings.map { ($0.id, origin.distance(to: $0.location)) },
      uniquingKeysWith: { first, _ in first })
  }

  /// Asks the user for location permission if they haven't been asked yet.
  /// - Returns: `true` if the permission prompt was shown, `false` if it was already answered or pending.
  /// - Throws: `LocationServiceError.locationPermissionsDenied` if the user has denied permission.
  public func requestLocationPermission() throws -> Bool {
    try locationService.requestLocationPermissions()
  }

  /// Retrieves buildings closest to the given building
  public func getBuildingsNearest(from building: Building, limit: Int) async -> Result<[NearbyBuilding], FetchBuildingsError> {
    switch await getBuildings() {
    case .success(let buildings):
      let otherBuildings = buildings.filter { $0.id != building.id }
      return .success(nearestBuildings(otherBuildings, from: building.location, limit: limit))

    case .failure(let error):
      return .failure(error)
    }
  }

  public func filterBuildingsByQueryString(_ buildings: CampusBuildings, by query: String) -> CampusBuildings {
    let filter: ([Building]) -> [Building] = { buildings in
      guard !query.isEmpty else { return buildings }
      return buildings.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    return (
      upper: filter(buildings.upper),
      middle: filter(buildings.middle),
      lower: filter(buildings.lower))
  }

  public func filterBuildingsByQueryString(_ buildings: [Building], by query: String) -> [Building] {
    let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedQuery.isEmpty else {
      return buildings
    }

    let lowercasedQuery = trimmedQuery.lowercased()

    return buildings.filter { building in
      building.name.lowercased().contains(lowercasedQuery) ||
        building.aliases.contains { alias in
          alias.lowercased().contains(lowercasedQuery)
        }
    }
  }

  /// Every building, each listed once, in the order the service returns them. The one place
  /// duplicate buildings are removed.
  public func getBuildings() async -> Result<[Building], FetchBuildingsError> {
    await buildingService.getBuildings().map { buildings in
      var seenIDs = Set<String>()
      return buildings.filter { seenIDs.insert($0.id).inserted }
    }
  }

  public func getBuildings(sortedBy sortOptions: Building.SortOptions) async -> Result<[Building], FetchBuildingsError> {
    await getBuildings().map { sortOptions.sort($0) }
  }

  // MARK: Private

  private let buildingService: any BuildingService
  private let locationService: any LocationService

  /// The closest `limit` buildings to `origin`, skipping buildings with no free rooms.
  private func nearestBuildings(_ buildings: [Building], from origin: Location, limit: Int) -> [NearbyBuilding] {
    let withFreeRooms = buildings.filter { $0.numberOfAvailableRooms != 0 }
    return Building.SortOptions.nearest(to: origin.coordinate)
      .sort(withFreeRooms)
      .prefix(max(limit, 0))
      .map { NearbyBuilding(building: $0, distanceInMetres: origin.distance(to: $0.location)) }
  }

}
