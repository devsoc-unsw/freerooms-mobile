import Foundation
import Networking
import Testing
@testable import Buildings

struct BuildingServiceTests {

  // MARK: Internal

  @Test("Building service loads no buildings with no error")
  func getsEmptyBuildingsWithNoError() async {
    // Given
    let buildings: [RemoteBuilding] = []
    let mockBuildingLoader = MockBuildingLoader(loads: [])
    let buildingService = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await buildingService.getBuildings()

    // Then
    expect(res, toFetch: buildings)
  }

  @Test("Building service loads five buildings with no errors")
  func getsFiveBuildingsWithNoError() async {
    // Given
    let buildings: [RemoteBuilding] = createBuildings(5)
    let mockBuildingLoader = MockBuildingLoader(loads: buildings)
    let buildingService = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await buildingService.getBuildings()

    // Then
    expect(res, toFetch: buildings)
  }

  @Test("Building service loads twenty-five buildings with no errors")
  func getsTwentyFiveBuildingsWithNoError() async {
    // Given
    let buildings: [RemoteBuilding] = createBuildings(25)
    let mockBuildingLoader = MockBuildingLoader(loads: buildings)
    let buildingService = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await buildingService.getBuildings()

    // Then
    expect(res, toFetch: buildings)
  }

  @Test("Building service loads fifty buildings with no errors")
  func getsFiftyBuildingsWithNoError() async {
    // Given
    let buildings: [RemoteBuilding] = createBuildings(50)
    let mockBuildingLoader = MockBuildingLoader(loads: buildings)
    let buildingService = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await buildingService.getBuildings()

    // Then
    expect(res, toFetch: buildings)
  }

  @Test("Building service loads hundred buildings with no errors")
  func getsHundredBuildingsWithNoError() async {
    // Given
    let buildings: [RemoteBuilding] = createBuildings(100)
    let mockBuildingLoader = MockBuildingLoader(loads: buildings)
    let buildingService = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await buildingService.getBuildings()

    // Then
    expect(res, toFetch: buildings)
  }

  @Test("Building service returns error when building loader fails")
  func failsBuildingServiceWhenBuildingLoaderFails() async {
    // Given
    let mockBuildingLoader = MockBuildingLoader(throws: NetworkCodableLoader<RemoteBuilding>.Error.connectivity)
    let buildingService = BuildingService(buildingLoader: mockBuildingLoader)

    // When
    let res = await buildingService.getBuildings()

    // Then
    expect(res, toThrow: NetworkCodableLoader<RemoteBuilding>.Error.connectivity)
  }

  // MARK: Private

  private func expect(_ res: BuildingService.Result, toThrow error: Swift.Error) {
    switch res {
    case .failure(_): break
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: BuildingService.Result, toFetch _: [RemoteBuilding]) {
    switch res {
    case .success(let buildings):
      #expect(buildings == buildings)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

  private func createBuildings(_ count: Int) -> [RemoteBuilding] {
    var buildings: [RemoteBuilding] = []
    for _ in 0..<count {
      buildings.append(RemoteBuilding(
        buildingName: "name",
        buildingId: UUID(),
        buildingLatitude: 1.0,
        buildingLongitude: 1.0,
        buildingAliases: []))
    }
    return buildings
  }
}
