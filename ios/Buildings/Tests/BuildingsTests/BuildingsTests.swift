import Testing
@testable import Buildings

// MARK: - GetBuildingByCampusSectionTest

struct GetBuildingByCampusSectionTest {
  @Test
  func sortByAscending() {
    // Given
    let mockBuildingService = MockBuildingService()
    mockBuildingService.addBuilding(createUpperCampusBuilding())
    mockBuildingService.addBuilding(createLowerCampusBuilding())
    mockBuildingService.addBuilding(createMiddleCampusBuilding())

    let sut = BuildingInteractor(buildingService: mockBuildingService)

    // When
    let buildings = sut.getBuildingSortedByCampusSection(inAscendingOrder: true)

    // Then
    #expect(buildings.count == 3)
    #expect(buildings[0].gridReference?.campusSection == .lower) // Lower campus building should be first
    #expect(buildings[1].gridReference?.campusSection == .middle) // Middle campus building should be second
    #expect(buildings[2].gridReference?.campusSection == .upper) // Upper campus building should be last
  }

  @Test
  func sortByDescending() {
    // Given
    let mockBuildingService = MockBuildingService()
    mockBuildingService.addBuilding(createUpperCampusBuilding())
    mockBuildingService.addBuilding(createLowerCampusBuilding())
    mockBuildingService.addBuilding(createMiddleCampusBuilding())

    let sut = BuildingInteractor(buildingService: mockBuildingService)

    // When
    let buildings = sut.getBuildingSortedByCampusSection(inAscendingOrder: false)

    // Then
    #expect(buildings.count == 3)
    #expect(buildings[0].gridReference?.campusSection == .upper) // Lower campus building should be first
    #expect(buildings[1].gridReference?.campusSection == .middle) // Middle campus building should be second
    #expect(buildings[2].gridReference?.campusSection == .lower) // Upper campus building should be last
  }

  /// Helper methods to create test buildings
  func createLowerCampusBuilding() -> Building {
    Building(
      name: "Law Library",
      id: "K-F8",
      latitude: 0,
      longitude: 0,
      aliases: ["Law Library"],
      numberOfAvailableRooms: 0)
  }

  func createMiddleCampusBuilding() -> Building {
    Building(
      name: "Quadrangle",
      id: "K-E15",
      latitude: 0,
      longitude: 0,
      aliases: ["Quad"],
      numberOfAvailableRooms: 0)
  }

  func createUpperCampusBuilding() -> Building {
    Building(
      name: "Patricia O Shane",
      id: "K-E19",
      latitude: 0,
      longitude: 0,
      aliases: ["Central Lecture Block"],
      numberOfAvailableRooms: 0)
  }
}

// MARK: - GridReferenceTest

struct GridReferenceTest {
  @Test
  func upperCampusBuildingTest() {
    // Given
    let building = Building(
      name: "Patricia O Shane",
      id: "K-E19",
      latitude: -33.917177,
      longitude: 151.232511,
      aliases: ["Central Lecture Block"],
      numberOfAvailableRooms: 0)

    // When
    let sut = building.gridReference!

    // Then
    #expect(sut.campusCode == "K")
    #expect(sut.sectionCode == "E")
    #expect(sut.sectionNumber == 19)
    #expect(sut.campusSection == CampusSection.upper)
  }

  @Test
  func middleCampusBuildingTest() {
    // Given
    let building = Building(
      name: "Quadrangle",
      id: "K-E15",
      latitude: 0.0,
      longitude: 0.0,
      aliases: ["Quad"],
      numberOfAvailableRooms: 0)

    // When
    let sut = building.gridReference!

    // Then
    #expect(sut.campusCode == "K")
    #expect(sut.sectionCode == "E")
    #expect(sut.sectionNumber == 15)
    #expect(sut.campusSection == CampusSection.middle)
  }

  @Test
  func lowerCampusBuildingTest() {
    // Given
    let building = Building(
      name: "Law Library",
      id: "K-F8",
      latitude: 0.0,
      longitude: 0.0,
      aliases: ["Law Library"],
      numberOfAvailableRooms: 0)

    // When
    let sut = building.gridReference!

    // Then
    #expect(sut.campusCode == "K")
    #expect(sut.sectionCode == "F")
    #expect(sut.sectionNumber == 8)
    #expect(sut.campusSection == CampusSection.lower)
  }

  @Test
  func testCampusSectionSortingAscending() {
    // Given
    var sut: [CampusSection] = [.upper, .middle, .lower]

    // When
    sut.sort(by: <)

    // Then
    #expect(sut == [.lower, .middle, .upper])
  }

  @Test
  func testCampusSectionSortingDescending() {
    // Given
    var sut: [CampusSection] = [.middle, .upper, .lower]

    // When
    sut.sort(by: >)

    // Then
    #expect(sut == [.upper, .middle, .lower])
  }

}

// MARK: - MockBuildingService

class MockBuildingService: BuildingServiceProtocol {

  // MARK: Internal

  func getBuildings() -> [Building] {
    buildings
  }

  func addBuilding(_ building: Building) {
    buildings.append(building)
  }

  func clearBuildings() {
    buildings.removeAll()
  }

  // MARK: Private

  private var buildings: [Building] = []

}
