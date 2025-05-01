//
//  BuildingLoaderTests.swift
//  Buildings
//
//  Created by Chris Wong on 1/5/2025.
//

import Testing
import Buildings

struct BuildingLoaderTests {
  @Test("Building loader loads zero buildings with no errors")
  func loadsEmptyBuildingsWithNoError() async {
    // Given
    let remoteBuildings = [RemoteBuilding]()
    let mockRemoteBuildingLoader = MockRemoteBuildingLoader(loads: remoteBuildings)
    let sut = LiveBuildingLoader(remoteBuildingLoader: mockRemoteBuildingLoader)
    
    // When
    let res = await sut.fetch()

    // Then
    let buildings = [Building]()
    expect(res, toFetch: buildings)
  }
  
  @Test("Building loader loads one buildings with no errors")
  func loadsOneBuildingsWithNoError() async {
    // Given
    let remoteBuildings = createRemoteBuildings(1)
    let mockRemoteBuildingLoader = MockRemoteBuildingLoader(loads: remoteBuildings)
    let sut = LiveBuildingLoader(remoteBuildingLoader: mockRemoteBuildingLoader)
    
    // When
    let res = await sut.fetch()

    // Then
    let buildings = createBuilding(1)
    expect(res, toFetch: buildings)
  }

  @Test("Building loader loads hundred buildings with no errors")
  func loadsHundredBuildingsWithNoError() async {
    // Given
    let remoteBuildings: [RemoteBuilding] = createRemoteBuildings(100)
    let mockRemoteBuildingLoader = MockRemoteBuildingLoader(loads: remoteBuildings)
    let sut = LiveBuildingLoader(remoteBuildingLoader: mockRemoteBuildingLoader)

    // When
    let res = await sut.fetch()

    // Then
    let buildings = createBuilding(100)
    expect(res, toFetch: buildings)
  }

  @Test("Building loader return error when failed")
  func buildingLoaderFailsWhenRemoteBuildingLoaderFails() async {
    // Given
    let mockRemoteBuildingLoader = MockRemoteBuildingLoader(throws: BuildingLoaderError.connectivity)
    let sut = LiveBuildingLoader(remoteBuildingLoader: mockRemoteBuildingLoader)

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toThrow: BuildingLoaderError.connectivity)
  }
  
  private func createRemoteBuildings(_ count: Int) -> [RemoteBuilding] {
    var remoteBuildings: [RemoteBuilding] = []
    for _ in 0..<count {
      remoteBuildings.append(RemoteBuilding(name: "name", id: "123", latitude: 1.0, longitude: 1.0, aliases: ["A", "B"], numberOfAvailableRooms: 10))
    }
    return remoteBuildings
  }
  
  private func createBuilding(_ count: Int) -> [Building] {
    var buildings: [Building] = []
    for _ in 0..<count {
      buildings.append(Building(name: "name", id: "123", latitude: 1.0, longitude: 1.0, aliases: ["A", "B"], numberOfAvailableRooms: 10))
    }
    return buildings
  }
  
  private func expect(_ res: LiveBuildingLoader.Result, toThrow error: BuildingLoaderError) {
    switch res {
    case .failure(let error):
      #expect(error == error)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: LiveBuildingLoader.Result, toFetch _: [Building]) {
    switch res {
    case .success(let buildings):
      #expect(buildings == buildings)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

}
