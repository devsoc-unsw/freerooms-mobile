//
//  GetBuildingByAvailableRoomsTest.swift
//  Buildings
//
//  Created by Shabinda Sarkaria on 11/6/2025.
//

import Testing
@testable import Location
@testable import LocationTestsUtils
@testable import Buildings

// MARK: Black Box Tests
struct GetBuildingByAvailableRoomsTest {
    @Test("Returns buildings sorted in descending order by number of available rooms")
      func returnsBuildingsSortedByAvailableRoomsDescending() async {
        // Given
        let buildings = [
          Building(name: "Quadrangle", id: "K-E15", latitude: 0, longitude: 0, aliases: ["Quad"], numberOfAvailableRooms: 3),
          Building(name: "Patricia O Shane", id: "K-E19", latitude: 0, longitude: 0, aliases: ["CLB", "Central Learning Block"], numberOfAvailableRooms: 7),
          Building(name: "Law Library", id: "K-F8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1)
        ]

          let mockLoader = MockBuildingLoader(loads: buildings)
          let buildingService = LiveBuildingService(buildingLoader: mockLoader)
          let locationManager = MockLocationManager()
          let locationService = LocationService(locationManager: locationManager)
          let sut = BuildingInteractor(buildingService: buildingService, locationService: locationService)
          

        // When
          let result = await sut.getBuildingsSortedByAvailableRooms()

          // Then
          let expectedOrder = ["Patricia O Shane", "Quadrangle", "Law Library"]
          let actualOrder = result.map(\.name)
          #expect(actualOrder == expectedOrder)
      }
    
    @Test("Returns nil buildings at the end of the list, still in descending order")
    func returnsBuildingsNilAtEndSortedByAvaliableRoomsDescending() async {
        // Given
        let buildings = [
          Building(name: "Quadrangle", id: "K-E15", latitude: 0, longitude: 0, aliases: ["Quad"], numberOfAvailableRooms: nil),
          Building(name: "Patricia O Shane", id: "K-E19", latitude: 0, longitude: 0, aliases: ["CLB", "Central Learning Block"], numberOfAvailableRooms: 7),
          Building(name: "Law Library", id: "K-F8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 0),
          Building(name: "McGill Library", id: "K-F10", latitude: 0, longitude: 0, aliases: ["McGill Lib"], numberOfAvailableRooms: 5),
          Building(name: "Main Library" , id: "K-F11", latitude: 0, longitude: 0, aliases: ["Main Lib"], numberOfAvailableRooms: 10),
        ]
        
        let mockLoader = MockBuildingLoader(loads: buildings)
        let buildingService = LiveBuildingService(buildingLoader: mockLoader)
        let locationManager = MockLocationManager()
        let locationService = LocationService(locationManager: locationManager)
        let sut = BuildingInteractor(buildingService: buildingService, locationService: locationService)
        
        // When
          let result = await sut.getBuildingsSortedByAvailableRooms()

          // Then
          let expectedOrder = ["Main Library", "Patricia O Shane", "McGill Library", "Law Library", "Quadrangle"]
          let actualOrder = result.map(\.name)
          #expect(actualOrder == expectedOrder)
    }
    
    @Test("No buildings should return an empty list")
    func returnsBuildingsEmptyList() async {
        let mockLoader = MockBuildingLoader(loads: [])
        let buildingService = LiveBuildingService(buildingLoader: mockLoader)
        let locationManager = MockLocationManager()
        let locationService = LocationService(locationManager: locationManager)
        let sut = BuildingInteractor(buildingService: buildingService, locationService: locationService)
        
        #expect(await sut.getBuildingsSortedByAvailableRooms() == [])
    }
}
