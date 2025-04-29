//
//  BuildingInteractor.swift
//  Buildings
//
//  Created by Anh Nguyen on 27/4/2025.
//

import Foundation
import CoreLocation
import Location

final class BuildingInteractor {
    
    private let buildingService: BuildingService
    private let locationService: LocationService

    init(buildingService: BuildingService = BuildingService(), locationService: LocationService = LocationService()) {
        self.buildingService = buildingService
        self.locationService = locationService
    }

    func getBuildingsSortedByAvailableRooms() -> [Building] {
        fatalError("TODO: Implement")
    }

    func getBuildingsSortedAlphabetically(inAscendingOrder _: Bool) -> [Building] {
        fatalError("TODO: Implement")
    }

    func getBuildingsSortedByDistance(inAscendingOrder: Bool) -> [Building] {
        let buildings = buildingService.getBuildings()
        
        let currentLocation: Location
        do {
            currentLocation = try locationService.getCurrentLocation()
        } catch {
            return []
        }
        
        let sortedBuildings = buildings.sorted { (building1, building2) -> Bool in
            let distance1 = calculateDistance(from: currentLocation, to: building1)
            let distance2 = calculateDistance(from: currentLocation, to: building2)
            return inAscendingOrder ? distance1 < distance2 : distance1 > distance2
        }
        
        return sortedBuildings

        /*
        // More efficient?
        let buildingsWithDistances = buildings.map { building -> (building: Building, distance: CLLocationDistance) in
            let distance = calculateDistance(from: currentLocation, to: building)
            return (building, distance)
        }
        
        let sortedBuildingsWithDistances = buildingsWithDistances.sorted { lhs, rhs in
            return inAscendingOrder ? lhs.distance < rhs.distance : lhs.distance > rhs.distance
        }
        
        return sortedBuildingsWithDistances.map { $0.building }
        */
    }
    
    private func calculateDistance(from location: Location, to building: Building) -> CLLocationDistance {
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let buildingLocation = CLLocation(latitude: building.latitude, longitude: building.longitude)
        return userLocation.distance(from: buildingLocation)
    }
}
