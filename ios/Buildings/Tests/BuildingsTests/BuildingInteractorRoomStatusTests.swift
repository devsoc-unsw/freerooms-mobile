//
//  BuildingInteractorRoomStatusTests.swift
//  BuildingsTests
//
//  Created by Muqueet Mohsen Chowdhury on 2/9/2025.
//

import BuildingInteractors
import BuildingModels
import BuildingTestUtils
import Foundation
import LocationTestsUtils
import RoomModels
import RoomTestUtils
import Testing

struct BuildingInteractorRoomStatusTests {

  @Test("getBuildingsWithRoomStatus merges room status data with offline buildings")
  func mergesRoomStatusWithOfflineBuildings() async {
    let mockBuildingService = MockBuildingService()
    let mockLocationService = MockLocationService()
    let mockRoomStatusLoader = MockRoomStatusLoader()

    let offlineBuildings = [
      Building(name: "Building A", id: "K-G27", latitude: -33.91852, longitude: 151.235664, aliases: []),
      Building(name: "Building B", id: "K-J17", latitude: -33.918527, longitude: 151.23126, aliases: []),
    ]
    mockBuildingService.stubSuccess(offlineBuildings)

    let roomStatusResponse: RemoteRoomStatus = [
      "K-G27": BuildingRoomStatus(numAvailable: 7, roomStatuses: [:]),
      "K-J17": BuildingRoomStatus(numAvailable: 16, roomStatuses: [:]),
    ]
    mockRoomStatusLoader.stubSuccess(roomStatusResponse)

    let interactor = BuildingInteractor(
      buildingService: mockBuildingService,
      locationService: mockLocationService,
      roomStatusLoader: mockRoomStatusLoader)

    let result = await interactor.getBuildingsWithRoomStatus()

    switch result {
    case .success(let buildings):
      #expect(buildings.count == 2)
      #expect(buildings[0].numberOfAvailableRooms == 7)
      #expect(buildings[1].numberOfAvailableRooms == 16)

    case .failure:
      Issue.record("Expected success")
    }
  }

  @Test("getBuildingsWithRoomStatus falls back to offline data when network fails")
  func fallsBackToOfflineDataOnNetworkFailure() async {
    let mockBuildingService = MockBuildingService()
    let mockLocationService = MockLocationService()
    let mockRoomStatusLoader = MockRoomStatusLoader()

    let offlineBuildings = [
      Building(
        name: "Building A",
        id: "K-G27",
        latitude: -33.91852,
        longitude: 151.235664,
        aliases: [],
        numberOfAvailableRooms: 5),
    ]
    mockBuildingService.stubSuccess(offlineBuildings)
    mockRoomStatusLoader.stubFailure(.connectivity)

    let interactor = BuildingInteractor(
      buildingService: mockBuildingService,
      locationService: mockLocationService,
      roomStatusLoader: mockRoomStatusLoader)

    let result = await interactor.getBuildingsWithRoomStatus()

    switch result {
    case .success(let buildings):
      #expect(buildings.count == 1)
      #expect(buildings[0].numberOfAvailableRooms == 5) // Original offline value preserved
    case .failure:
      Issue.record("Expected success with offline data")
    }
  }

  @Test("getBuildingsWithRoomStatus works without room status loader")
  func worksWithoutRoomStatusLoader() async {
    let mockBuildingService = MockBuildingService()
    let mockLocationService = MockLocationService()

    let offlineBuildings = [
      Building(
        name: "Building A",
        id: "K-G27",
        latitude: -33.91852,
        longitude: 151.235664,
        aliases: [],
        numberOfAvailableRooms: 3),
    ]
    mockBuildingService.stubSuccess(offlineBuildings)

    let interactor = BuildingInteractor(
      buildingService: mockBuildingService,
      locationService: mockLocationService,
      roomStatusLoader: nil)

    let result = await interactor.getBuildingsWithRoomStatus()

    switch result {
    case .success(let buildings):
      #expect(buildings.count == 1)
      #expect(buildings[0].numberOfAvailableRooms == 3) // Original offline value preserved
    case .failure:
      Issue.record("Expected success with offline data")
    }
  }

  @Test("getBuildingsWithRoomStatus preserves offline data for buildings not in room status response")
  func preservesOfflineDataForMissingBuildings() async {
    let mockBuildingService = MockBuildingService()
    let mockLocationService = MockLocationService()
    let mockRoomStatusLoader = MockRoomStatusLoader()

    let offlineBuildings = [
      Building(
        name: "Building A",
        id: "K-G27",
        latitude: -33.91852,
        longitude: 151.235664,
        aliases: [],
        numberOfAvailableRooms: 5),
      Building(
        name: "Building B",
        id: "K-MISSING",
        latitude: -33.918527,
        longitude: 151.23126,
        aliases: [],
        numberOfAvailableRooms: 10),
    ]
    mockBuildingService.stubSuccess(offlineBuildings)

    // Only provide room status for one building
    let roomStatusResponse: RemoteRoomStatus = [
      "K-G27": BuildingRoomStatus(numAvailable: 7, roomStatuses: [:]),
    ]
    mockRoomStatusLoader.stubSuccess(roomStatusResponse)

    let interactor = BuildingInteractor(
      buildingService: mockBuildingService,
      locationService: mockLocationService,
      roomStatusLoader: mockRoomStatusLoader)

    let result = await interactor.getBuildingsWithRoomStatus()

    switch result {
    case .success(let buildings):
      #expect(buildings.count == 2)
      #expect(buildings[0].numberOfAvailableRooms == 7) // Updated from network
      #expect(buildings[1].numberOfAvailableRooms == 10) // Preserved offline value
    case .failure:
      Issue.record("Expected success")
    }
  }
}
