//
//  BuildingInteractor.swift
//  Buildings
//
//  Created by Anh Nguyen on 27/4/2025.
//

import BuildingModels
import BuildingServices
import Foundation
import Location
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
  ///   - roomStatusLoader: Optional loader for real-time room status data
  public init(
    buildingService: BuildingService,
    locationService: LocationService,
    roomStatusLoader: RoomStatusLoader? = nil)
  {
    self.buildingService = buildingService
    self.locationService = locationService
    self.roomStatusLoader = roomStatusLoader
  }

  // MARK: Public

  public func getBuildingsFilteredByCampusSection(_ campusSection: CampusSection) -> Result<[Building], Error> {
    switch buildingService.getBuildings() {
    case .success(let buildings):
      let filtered = buildings.filter { $0.gridReference.campusSection == campusSection }
      return .success(filtered)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getBuildingsSortedByDistance(inAscendingOrder: Bool) -> Result<[Building], Error> {
    switch buildingService.getBuildings() {
    case .success(let buildings):
      do {
        let currentLocation = try locationService.getCurrentLocation()

        // Compute each building's distance once, then sort
        let sorted = buildings
          .map { (building: Building) -> (Building, Double) in
            (building, calculateDistance(from: currentLocation, to: building))
          }
          .sorted { inAscendingOrder ? $0.1 < $1.1 : $0.1 > $1.1 }
          .map { $0.0 }
        return .success(sorted)
      } catch {
        return .failure(error)
      }

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getBuildingsSortedAlphabetically(buildings: [Building], order: Bool) -> [Building] {
    buildings.sorted { a, b in
      order ? a.name < b.name : a.name > b.name
    }
  }

  // MARK: Package

  /// Fetches buildings and merges with room status data from the network.
  /// Falls back to offline data if network request fails.
  /// - Returns: Result containing buildings with updated room availability or an error
  package func getBuildingsWithRoomStatus() async -> Result<[Building], Error> {
    switch buildingService.getBuildings() {
    case .success(let offlineBuildings):
      guard let roomStatusLoader else {
        return .success(offlineBuildings)
      }

      switch await roomStatusLoader.fetchRoomStatus() {
      case .success(let roomStatusResponse):
        let buildingsWithStatus = offlineBuildings.map { building in
          let buildingRoomStatus = roomStatusResponse[building.id]
          return Building(
            name: building.name,
            id: building.id,
            latitude: building.latitude,
            longitude: building.longitude,
            aliases: building.aliases,
            numberOfAvailableRooms: buildingRoomStatus?.numAvailable ?? building.numberOfAvailableRooms)
        }
        return .success(buildingsWithStatus)

      case .failure:
        return .success(offlineBuildings)
      }

    case .failure(let error):
      return .failure(error)
    }
  }

  package func getBuildingsSortedAlphabetically(inAscendingOrder: Bool) -> Result<[Building], Error> {
    switch buildingService.getBuildings() {
    case .success(let buildings):
      let sorted = buildings.sorted { a, b in
        inAscendingOrder ? a.name < b.name : a.name > b.name
      }
      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  // MARK: Internal

  func getBuildingsSortedByAvailableRooms(inAscendingOrder: Bool) -> Result<[Building], Error> {
    switch buildingService.getBuildings() {
    case .success(let buildings):
      // no valid data, return as is
      guard buildings.contains(where: { $0.numberOfAvailableRooms != nil }) else {
        return .success(buildings)
      }
      let sorted = buildings.sorted { (a: Building, b: Building) in
        inAscendingOrder
          ? (a.numberOfAvailableRooms ?? 0) < (b.numberOfAvailableRooms ?? 0)
          : (a.numberOfAvailableRooms ?? 0) > (b.numberOfAvailableRooms ?? 0)
      }
      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  func getBuildingSortedByCampusSection(inAscendingOrder: Bool) -> Result<[Building], Error> {
    switch buildingService.getBuildings() {
    case .success(let buildings):
      var sorted = buildings
      if inAscendingOrder {
        sorted = buildings.sorted { $0.gridReference.campusSection.rawValue < $1.gridReference.campusSection.rawValue }
      } else {
        sorted = buildings.sorted { $0.gridReference.campusSection.rawValue > $1.gridReference.campusSection.rawValue }
      }

      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  // MARK: Private

  private let buildingService: BuildingService
  private let locationService: LocationService
  private let roomStatusLoader: RoomStatusLoader?

  /// Calculates the squared distance between a location and a building.
  /// Uses squared distance for performance (avoiding square root calculation).
  /// - Parameters:
  ///   - location: Starting location
  ///   - building: Target building
  /// - Returns: Squared distance value
  private func calculateDistance(from location: Location, to building: Building) -> Double {
    let dlat = building.latitude - location.latitude
    let dlon = building.longitude - location.longitude
    return dlat * dlat + dlon * dlon
  }

}
