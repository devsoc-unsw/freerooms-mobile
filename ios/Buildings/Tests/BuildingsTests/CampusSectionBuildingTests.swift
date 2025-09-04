

import Testing
@testable import BuildingInteractors
@testable import BuildingModels
@testable import BuildingServices
@testable import BuildingTestUtils
@testable import Location
@testable import LocationTestsUtils

// MARK: - GetBuildingByCampusSectionTest

struct GetBuildingByCampusSectionTest {
  @Test("Building interactor returns buildings in ascending order by campus reference")
  func sortByAscending() async {
    let mockBuildingService = MockBuildingService()
    mockBuildingService.addBuilding(createUpperCampusBuilding())
    mockBuildingService.addBuilding(createLowerCampusBuilding())
    mockBuildingService.addBuilding(createMiddleCampusBuilding())

    let locationManager = MockLocationManager()
    let locationService = LiveLocationService(locationManager: locationManager)

    let sut = BuildingInteractor(buildingService: mockBuildingService, locationService: locationService)

    // When
    let buildings = await sut.getBuildingSortedByCampusSection(inAscendingOrder: true)
    guard case .success(let buildings) = buildings else {
      Issue.record("get building should not fail")
      return
    }

    // Then
    #expect(buildings.count == 3)
    #expect(buildings[0].gridReference.campusSection == CampusSection.lower) // Lower campus building should be first
    #expect(buildings[1].gridReference.campusSection == CampusSection.middle) // Middle campus building should be second
    #expect(buildings[2].gridReference.campusSection == CampusSection.upper) // Upper campus building should be last
  }

  @Test("Building interactor returns buildings in descending order by campus reference")
  func sortByDescending() async {
    // Given
    let mockBuildingService = MockBuildingService()
    mockBuildingService.addBuilding(createUpperCampusBuilding())
    mockBuildingService.addBuilding(createLowerCampusBuilding())
    mockBuildingService.addBuilding(createMiddleCampusBuilding())

    let locationManager = MockLocationManager()
    let locationService = LiveLocationService(locationManager: locationManager)

    let sut = BuildingInteractor(buildingService: mockBuildingService, locationService: locationService)

    // When
    let buildings = await sut.getBuildingSortedByCampusSection(inAscendingOrder: false)
    guard case .success(let buildings) = buildings else {
      Issue.record("get building should not fail")
      return
    }

    // Then
    #expect(buildings.count == 3)
    #expect(buildings[0].gridReference.campusSection == .upper) // Lower campus building should be first
    #expect(buildings[1].gridReference.campusSection == .middle) // Middle campus building should be second
    #expect(buildings[2].gridReference.campusSection == .lower) // Upper campus building should be last
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
  @Test("Grid reference properly identifies upper campus building")
  func upperCampusBuildingParsingTest() {
    // Given
    let building = Building(
      name: "Patricia O Shane",
      id: "K-E19",
      latitude: -33.917177,
      longitude: 151.232511,
      aliases: ["Central Lecture Block"],
      numberOfAvailableRooms: 0)

    // When
    let sut = building.gridReference

    // Then
    #expect(sut.campusCode == "K")
    #expect(sut.sectionCode == "E")
    #expect(sut.sectionNumber == 19)
    #expect(sut.campusSection == CampusSection.upper)
  }

  @Test("Grid reference properly identify middle campus building")
  func middleCampusBuildingParsingTest() {
    // Given
    let building = Building(
      name: "Quadrangle",
      id: "K-E15",
      latitude: 0.0,
      longitude: 0.0,
      aliases: ["Quad"],
      numberOfAvailableRooms: 0)

    // When
    let sut = building.gridReference

    // Then
    #expect(sut.campusCode == "K")
    #expect(sut.sectionCode == "E")
    #expect(sut.sectionNumber == 15)
    #expect(sut.campusSection == CampusSection.middle)
  }

  @Test("Grid reference properly identify lower campus building")
  func lowerCampusBuildingParsingTest() {
    // Given
    let building = Building(
      name: "Law Library",
      id: "K-F8",
      latitude: 0.0,
      longitude: 0.0,
      aliases: ["Law Library"],
      numberOfAvailableRooms: 0)

    // When
    let sut = building.gridReference

    // Then
    #expect(sut.campusCode == "K")
    #expect(sut.sectionCode == "F")
    #expect(sut.sectionNumber == 8)
    #expect(sut.campusSection == CampusSection.lower)
  }

  @Test("initialize grid reference with multiple dashes in building ID")
  func invalidBuildingIDWithDashesParsingTest() {
    // Given
    let building = Building(
      name: "Law Library",
      id: "K-F-C",
      latitude: 0.0,
      longitude: 0.0,
      aliases: ["Leon Town"],
      numberOfAvailableRooms: 0)

    // When
    let sut = building.gridReference

    // Then
    #expect(sut.campusCode == "?")
  }

  @Test("initialize grid reference with invalid building ID")
  func invalidBuildingIDParsingTest() {
    // Given
    let building = Building(
      name: "Safety Culture",
      id: "M-CD",
      latitude: 0.0,
      longitude: 0.0,
      aliases: ["Hanoi"],
      numberOfAvailableRooms: 0)

    // When
    let sut = building.gridReference

    // Then
    #expect(sut.campusCode == "?")
  }

  @Test("campus section enum sorts correctly in ascending order")
  func testCampusSectionSortingAscending() {
    // Given
    var sut: [CampusSection] = [.upper, .middle, .lower]

    // When
    sut = sut.sorted { $0.rawValue < $1.rawValue }

    // Then
    #expect(sut == [.lower, .middle, .upper])
  }

  @Test("campus section enum sorts correctly in descending order")
  func testCampusSectionSortingDescending() {
    // Given
    var sut: [CampusSection] = [.middle, .upper, .lower]

    // When
    sut = sut.sorted { $0.rawValue > $1.rawValue }

    // Then
    #expect(sut == [.upper, .middle, .lower])
  }

}
