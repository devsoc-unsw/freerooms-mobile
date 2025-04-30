import Foundation
import Networking
import Testing
@testable import Buildings

struct BuildingServiceTests {

  // MARK: Internal

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
    let mockRemoteBuildingLoader = MockRemoteBuildingLoader(throws: LiveBuildingLoader.Error.connectivity)
    let sut = LiveBuildingLoader(remoteBuildingLoader: mockRemoteBuildingLoader)

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toThrow: NetworkCodableLoader<RemoteBuilding>.Error.connectivity)
  }
  
  @Test("Building service fetches zero buildings")
  func fetchZeroBuildingsFromBuildingService() async {
    // Given
    let buildings = [Building]()
    let mockBuildingLoader = MockBuildingLoader(loads: buildings)
    let sut = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await sut.getBuildings()

    // Then
    expect(res, toFetch: buildings)
  }
  
  @Test("Building service fetches one buildings")
  func fetchOneBuildingsFromBuildingService() async {
    // Given
    let buildings = createBuilding(1)
    let mockBuildingLoader = MockBuildingLoader(loads: buildings)
    let sut = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await sut.getBuildings()

    // Then
    expect(res, toFetch: buildings)
  }
  
  @Test("Building service fetches one hundred buildings")
  func fetchHundredBuildingsFromBuildingService() async {
    // Given
    let buildings = createBuilding(100)
    let mockBuildingLoader = MockBuildingLoader(loads: buildings)
    let sut = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await sut.getBuildings()

    // Then
    expect(res, toFetch: buildings)
  }
  
  @Test("Building service returns a connectivity error when loader fails")
  func buildingServiceReturnsConnectivityError() async {
    // Given
    let mockBuildingLoader = MockBuildingLoader(throws: LiveBuildingLoader.Error.connectivity)
    let sut = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await sut.getBuildings()

    // Then
    expect(res, toThrow: BuildingService.Error.connectivity)
  }

  // MARK: Private

  private func expect(_ res: BuildingService.Result, toThrow error: Swift.Error) {
    switch res {
    case .failure(_): break
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: BuildingService.Result, toFetch _: [Building]) {
    switch res {
    case .success(let buildings):
      #expect(buildings == buildings)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
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
}
