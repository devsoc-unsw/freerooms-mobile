//
//  GetBuildingAlphabeticallyTest.swift
//  Buildings
//
//  Created by Shabinda Sarkaria on 26/6/2025.
//

import Testing
@testable import Location
@testable import LocationTestsUtils
@testable import Buildings

struct GetBuildingAlphabeticallyTest {
    @Test("Ensure buildings return an empty list")
    func returnsBuildingsEmptyList() async {
        // Given
        let mockLoader = MockBuildingLoader(loads: [])
        let buildingService = LiveBuildingService(buildingLoader: mockLoader)
        let locationManager = MockLocationManager()
        let locationService = LocationService(locationManager: locationManager)
        let sut = BuildingInteractor(buildingService: buildingService, locationService: locationService)
        
        
        // When
        let result = await sut.getBuildingsSortedAlphabetically(inAscendingOrder: false)
        
        // Then
        guard case let .success(buildings) = result else {
            Issue.record("Expected success but got failure.")
            return
        }
        
        #expect (buildings.isEmpty)
        
    }
    
    @Test("Return buildings sorted by alphabetical order in descending order") func returnsBuildingsAlphabeticallySortedDescendingOrder() async {
        // Given
        let buildings = [
          Building(name: "Quadrangle", id: "K-E15", latitude: 0, longitude: 0, aliases: ["Quad"], numberOfAvailableRooms: 3),
          Building(name: "Patricia O Shane", id: "K-E19", latitude: 0, longitude: 0, aliases: ["CLB", "Central Learning Block"], numberOfAvailableRooms: 7),
          Building(name: "Law Library", id: "K-F8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
          Building(name: "AGSM", id: "K-G27", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 0),
          Building(name: "McGill Library", id: "K-F10", latitude: 0, longitude: 0, aliases: ["McGill Lib"], numberOfAvailableRooms: 5),
          Building(name: "Main Library" , id: "K-F11", latitude: 0, longitude: 0, aliases: ["Main Lib"], numberOfAvailableRooms: 6),
          Building(name: "Anita B. Lawrence Centre" , id: "K-H13", latitude: 0, longitude: 0, aliases: ["The Red Centre"], numberOfAvailableRooms: 6)
        ]

        let mockLoader = MockBuildingLoader(loads: buildings)
        let buildingService = LiveBuildingService(buildingLoader: mockLoader)
        let locationManager = MockLocationManager()
        let locationService = LocationService(locationManager: locationManager)
        let sut = BuildingInteractor(buildingService: buildingService, locationService: locationService)
        
        // When
        let result = await sut.getBuildingsSortedAlphabetically(inAscendingOrder: false)
        
        // Then
        let expectedOrder = ["Quadrangle", "Patricia O Shane", "McGill Library", "Main Library", "Law Library", "Anita B. Lawrence Centre", "AGSM"]
        guard case let .success(buildings) = result else {
          Issue.record("Failure, but expected success")
          return

        }
         
        let actualOrder = buildings.map(\.name)
        #expect (actualOrder == expectedOrder)
    }
    
    @Test("Return buildings sorted by alphabetical order in ascending order") func returnsBuildingsAlphabeticallySortedAscendingOrder() async {
        // Given
        let buildings = [
          Building(name: "Quadrangle", id: "K-E15", latitude: 0, longitude: 0, aliases: ["Quad"], numberOfAvailableRooms: 3),
          Building(name: "Patricia O Shane", id: "K-E19", latitude: 0, longitude: 0, aliases: ["CLB", "Central Learning Block"], numberOfAvailableRooms: 7),
          Building(name: "Law Library", id: "K-F8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
          Building(name: "AGSM", id: "K-G27", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 0),
          Building(name: "McGill Library", id: "K-F10", latitude: 0, longitude: 0, aliases: ["McGill Lib"], numberOfAvailableRooms: 5),
          Building(name: "Main Library" , id: "K-F11", latitude: 0, longitude: 0, aliases: ["Main Lib"], numberOfAvailableRooms: 6),
          Building(name: "Anita B. Lawrence Centre" , id: "K-H13", latitude: 0, longitude: 0, aliases: ["The Red Centre"], numberOfAvailableRooms: 6)
        ]

        let mockLoader = MockBuildingLoader(loads: buildings)
        let buildingService = LiveBuildingService(buildingLoader: mockLoader)
        let locationManager = MockLocationManager()
        let locationService = LocationService(locationManager: locationManager)
        let sut = BuildingInteractor(buildingService: buildingService, locationService: locationService)
        
        // When
        let result = await sut.getBuildingsSortedAlphabetically(inAscendingOrder: true)
        
        // Then
        let expectedOrder = ["AGSM", "Anita B. Lawrence Centre", "Law Library", "Main Library", "McGill Library", "Patricia O Shane", "Quadrangle"]
        guard case let .success(buildings) = result else {
          Issue.record("Failure, but expected success")
          return

        }
         
        let actualOrder = buildings.map(\.name)
        #expect(actualOrder == expectedOrder)
    }
}
