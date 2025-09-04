//
//  RoomInteractorTests.swift
//  Rooms
//
//  Created by Yanlin Li  on 3/9/2025.
//

import Foundation
import RoomModels
import Testing

@testable import Location
@testable import LocationTestsUtils
@testable import RoomInteractors
@testable import RoomServices
@testable import RoomTestUtils

// MARK: - RoomInteractorTests

enum RoomInteractorTests {
  struct RoomAlphabeticalOrdering {
    @Test("Returns rooms sorted alphabetically in ascending order")
    func returnsRoomsSortedAlpheticallyInAscendingOrder() {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsSortedAlphabetically(inAscendingOrder: true)

      // Then
      let expectResult = expectedRooms.sorted { $0.name < $1.name }

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectResult)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms sorted alphabetically in descending order")
    func returnsRoomsSortedAlpheticallyInDescendingOrder() {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsSortedAlphabetically(inAscendingOrder: false)

      // Then
      let expectResult = expectedRooms.sorted { $0.name > $1.name }

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectResult)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }
  }

  struct RoomFilteringByBuildingId {
    @Test("Returns rooms filtered by building id matching")
    func returnsRoomsFilteredByBuildingIdMatching() {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms, for: "K-H20")

      // When
      let result = sut.getRoomsFilteredAlphabeticallyByBuildingId(buildingId: "K-H20", inAscendingOrder: true)

      // Then
      let expectResult = createDifferentRooms()
        .filter { $0.buildingId == "K-H20" }
        .sorted { $0.name < $1.name }
      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectResult)

      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms filtered by building id not matching")
    func returnsRoomsFilteredByBuildingIdNotMatching() {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms, for: "K-P20")

      // When
      let result = sut.getRoomsFilteredAlphabeticallyByBuildingId(buildingId: "K-P20", inAscendingOrder: true)

      // Then
      let expectResult = expectedRooms
        .filter { $0.buildingId == "K-P20" }
        .sorted { $0.name < $1.name }

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectResult)

      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns all rooms filtered by all builingId matching")
    func returnsAllRoomsFilteredByAllBuildingIdMatching() {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByAllBuildingId(buildingIds: ["K-H20", "K-G6", "K-J17"])

      // Then
      var expectResult: [String: [Room]] = [:]
      for buildingId in ["K-H20", "K-G6", "K-J17"] {
        let filteredRooms = expectedRooms
          .filter { $0.buildingId == buildingId }
        expectResult[buildingId] = filteredRooms
      }

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectResult)
        #expect(actualResult.keys.count == 3)
        #expect(actualResult["K-H20"]!.count == 2)

      case .failure:
        Issue.record("Expected success, got failure")
      }
    }
  }

  struct RoomTypeFiltering {
    @Test("Returns rooms filtered by room type (usage) matching")
    func returnsRoomsFilteredByRoomTypeMatching() {
      // Given
      let expectedRooms = createRooms(1)
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByRoomType(usage: "LCTR")

      // Then
      let expectResult = createRooms(1)

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectResult)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms filtered by room type (usage) not matching")
    func returnsRoomsFilteredByRoomTypeNotMatching() {
      // Given
      let expectedRooms = createRooms(1)
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByRoomType(usage: "LAB")

      // Then
      let expectResult = createRooms(0)

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectResult)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }
  }

  struct RoomCampusLocationFiltering {
    @Test("Returns rooms filtered by lower campus")
    func returnsRoomsFilteredByLowerCampus() {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByCampusSection(CampusSection.lower)

      // Then
      let expectResultCount = 1

      switch result {
      case .success(let actualResult):
        #expect(actualResult.count == expectResultCount)
        #expect(actualResult.first!.abbreviation == "Block 105")

      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms filtered by middle campus")
    func returnsRoomsFilteredByMiddleCampus() {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByCampusSection(CampusSection.middle)

      // Then
      let expectResultCount = 1

      switch result {
      case .success(let actualResult):
        #expect(actualResult.count == expectResultCount)
        #expect(actualResult.first!.abbreviation == "Ainswth501")

      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms filtered by upper campus")
    func returnsRoomsFilteredByUpperCampus() {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByCampusSection(CampusSection.upper)

      // Then
      switch result {
      case .success(let actualResult):
        #expect(actualResult.count == 2)
        #expect(actualResult.first!.abbreviation == "CivEng 101")

      case .failure:
        Issue.record("Expected success, got failure")
      }
    }
  }

  struct RoomDurationFiltering {
    @Test("Returns rooms filtered by minimum 30 minutes")
    func returnsRoomsFilteredBy30MinutesOrMore() {
      // Given
      let expectedRooms = createDifferentRooms()
      // let expectedBookings = createBookings()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByDuration(for: 30)

      // Then
    }

    @Test("Returns rooms filtered by minimum 1 hour")
    func returnsRoomsFilteredByOneHourOrMore() {
      // Given
      let expectedRooms = createDifferentRooms()
      // let expectedBookings = createBookings()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByDuration(for: 60)

      // Then
    }

    @Test("Returns rooms filtered by minimum 2 hour")
    func returnsRoomsFilteredByTwoHoursOrMore() {
      // Given
      let expectedRooms = createDifferentRooms()
      // let expectedBookings = createBookings()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByDuration(for: 120)

      // Then
    }
  }
}

/// Function to make the building SUT
func makeRoomSUT(expect rooms: [Room], for buildingId: String? = nil, throw roomError: RoomLoaderError? = nil) -> RoomInteractor {
  let locationManager = MockLocationManager()
  let locationService: LocationService = LocationService(locationManager: locationManager)

  let mockLoader = MockRoomLoader()
  if roomError != nil {
    mockLoader.stubError(roomError!)
  } else if buildingId != nil {
    mockLoader.stubRooms(rooms, for: buildingId!)
  } else {
    mockLoader.stubRooms(rooms)
  }

  let roomService = LiveRoomService(roomLoader: mockLoader)

  return RoomInteractor(roomService: roomService, locationService: locationService)
}

func createDifferentRooms() -> [Room] {
  [
    Room(
      abbreviation: "Block 105",
      accessibility: [
        "Ventilation - Air conditioning",
        "Weekend Access",
        "Wheelchair access - teaching",
        "Wheelchair access - student",
      ],
      audioVisual: [
        "Document camera",
      ],
      buildingId: "K-G6",
      capacity: 20,
      floor: "Flat",
      id: "K-G6-105",
      infoTechnology: [
        "IT laptop connection",
        "Video data projector",
      ],
      latitude: -33.9169983869067,
      longitude: 151.226698499323,
      microphone: [],
      name: "Blockhouse 105",
      school: "GLOBL",
      seating: "Movable",
      usage: "TUSM",
      service: [],
      writingMedia: []),
    Room(
      abbreviation: "Ainswth501",
      accessibility: [],
      audioVisual: [],
      buildingId: "K-J17",
      capacity: 40,
      floor: "Flat",
      id: "K-J17-501",
      infoTechnology: [],
      latitude: -33.918793948030846,
      longitude: 151.23134411127646,
      microphone: [],
      name: "example",
      school: "example",
      seating: "example",
      usage: "TUSM",
      service: [],
      writingMedia: []),
    Room(
      abbreviation: "CivEng 101",
      accessibility: [],
      audioVisual: [],
      buildingId: "K-H20",
      capacity: 40,
      floor: "Tiered",
      id: "K-H20-101",
      infoTechnology: [],
      latitude: -33.918793948030846,
      longitude: 151.23134411127646,
      microphone: [],
      name: "example",
      school: "example",
      seating: "fixed",
      usage: "LCTR",
      service: [],
      writingMedia: []),
    Room(
      abbreviation: "CivEng 102",
      accessibility: [],
      audioVisual: [],
      buildingId: "K-H20",
      capacity: 40,
      floor: "Tiered",
      id: "K-H20-102",
      infoTechnology: [],
      latitude: -33.918793948030846,
      longitude: 151.23134411127646,
      microphone: [],
      name: "example",
      school: "example",
      seating: "fixed",
      usage: "LCTR",
      service: [],
      writingMedia: []),
  ]
}
