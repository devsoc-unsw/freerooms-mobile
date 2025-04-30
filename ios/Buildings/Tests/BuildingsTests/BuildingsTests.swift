import Testing
@testable import Buildings

// MARK: - GetBuildingByCampusSectionTest

struct GetBuildingByCampusSectionTest {
  @Test
  func sortByAscending() {
    // TODO
  }

  @Test
  func sortByDescending() {
    // TODO
  }

}

// MARK: - GridReferenceTest

struct GridReferenceTest {
  @Test
  func upperCampusBuildingTest() {
    let building = Building(
      name: "Patricia O Shane",
      id: "K-E19",
      latitude: -33.917177,
      longitude: 151.232511,
      aliases: ["Central Lecture Block"],
      numberOfAvailableRooms: 0)

    let sut = building.gridReference!

    #expect(sut.campusCode == "K")
    #expect(sut.sectionCode == "E")
    #expect(sut.sectionNumber == 19)
    #expect(sut.campusSection == CampusSection.upper)
  }

  @Test
  func middleCampusBuildingTest() {
    let building = Building(
      name: "Quadrangle",
      id: "K-E15",
      latitude: 0.0,
      longitude: 0.0,
      aliases: ["Quad"],
      numberOfAvailableRooms: 0)

    let sut = building.gridReference!

    #expect(sut.campusCode == "K")
    #expect(sut.sectionCode == "E")
    #expect(sut.sectionNumber == 15)
    #expect(sut.campusSection == CampusSection.middle)
  }

  @Test
  func lowerCampusBuildingTest() {
    let building = Building(
      name: "Law Library",
      id: "K-F8",
      latitude: 0.0,
      longitude: 0.0,
      aliases: ["Law Library"],
      numberOfAvailableRooms: 0)

    let sut = building.gridReference!

    #expect(sut.campusCode == "K")
    #expect(sut.sectionCode == "F")
    #expect(sut.sectionNumber == 8)
    #expect(sut.campusSection == CampusSection.lower)
  }
}
