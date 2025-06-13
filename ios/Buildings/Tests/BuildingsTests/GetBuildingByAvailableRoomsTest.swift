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
          let result = await sut.getBuildingsSortedByAvaliableRooms()

          // Then
          let expectedOrder = ["Patricia O Shane", "Quadrangle", "Law Library"]
          let actualOrder = result.map(\.name)
          #expect(actualOrder == expectedOrder)
      }
}
