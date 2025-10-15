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
@testable import TestingSupport

// MARK: - RoomInteractorTests

enum RoomInteractorTests {
  struct RoomAlphabeticalOrdering {
    @Test("Returns rooms sorted alphabetically in ascending order")
    func returnsRoomsSortedAlpheticallyInAscendingOrder() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsSortedAlphabetically(inAscendingOrder: true)

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
    func returnsRoomsSortedAlpheticallyInDescendingOrder() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsSortedAlphabetically(inAscendingOrder: false)

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
    func returnsRoomsFilteredByBuildingIdMatching() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms, for: "K-H20")

      // When
      let result = await sut.getRoomsFilteredAlphabeticallyByBuildingId(buildingId: "K-H20", inAscendingOrder: true)

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
    func returnsRoomsFilteredByBuildingIdNotMatching() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms, for: "K-P20")

      // When
      let result = await sut.getRoomsFilteredAlphabeticallyByBuildingId(buildingId: "K-P20", inAscendingOrder: true)

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
    func returnsAllRoomsFilteredByAllBuildingIdMatching() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)
      let buildingIds =
        [
          "K-G27",
          "K-J17",
          "K-H13",
          "K-E26",
          "K-D26",
          "K-G6",
          "K-E12",
          "K-H20",
          "K-B16",
          "K-K17",
          "K-F12",
          "K-G17",
          "K-D8",
          "K-D16",
          "K-F25",
          "K-F31",
          "K-F20",
          "K-G19",
          "K-F10",
          "K-J14",
          "K-F8",
          "K-F21",
          "K-E10",
          "K-F23",
          "K-D23",
          "K-C20",
          "K-J12",
          "K-K15",
          "K-E19",
          "K-K14",
          "K-E15",
          "K-F17",
          "K-M15",
          "K-E8",
          "K-F13",
          "K-C24",
          "K-E4",
          "K-H6",
          "K-H22",
          "K-C27",
          "K-G14",
          "K-G15",
          "K-J18",
        ]

      // When
      let result = await sut.getRoomsFilteredByAllBuildingId()

      // Then
      var expectResult: [String: [Room]] = [:]
      for buildingId in buildingIds {
        let filteredRooms = expectedRooms
          .filter { $0.buildingId == buildingId }
        expectResult[buildingId] = filteredRooms
      }

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectResult)
        #expect(actualResult["K-H20"]!.count == 2)

      case .failure:
        Issue.record("Expected success, got failure")
      }
    }
  }

  struct RoomTypeFiltering {
    @Test("Returns rooms filtered by room type (usage) matching")
    func returnsRoomsFilteredByRoomTypeMatching() async {
      // Given
      let expectedRooms = createRooms(1)
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsFilteredByRoomType(usage: "LCTR")

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
    func returnsRoomsFilteredByRoomTypeNotMatching() async {
      // Given
      let expectedRooms = createRooms(1)
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsFilteredByRoomType(usage: "LAB")

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
    func returnsRoomsFilteredByLowerCampus() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsFilteredByCampusSection(CampusSection.lower)

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
    func returnsRoomsFilteredByMiddleCampus() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsFilteredByCampusSection(CampusSection.middle)

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
    func returnsRoomsFilteredByUpperCampus() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsFilteredByCampusSection(CampusSection.upper)

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
    func returnsRoomsFilteredBy30MinutesOrMore() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(
        1,
        from: Date().addingTimeInterval(40 * 60),
        to: Date().addingTimeInterval(60 * 60))
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsFilteredByDuration(for: 30, roomBookings: roomBookingsMapped)

      // Then
      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedRooms)
        // swiftlint:disable:next no_direct_standard_out_logs
        print("Booking loader result: \(actualResult)")

      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms filtered by minimum 30 minutes with one room booked during current time")
    func returnsRoomsFilteredBy30MinutesOrMorDuringCurrentTime() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(
        1,
        from: Date(),
        to: Date().addingTimeInterval(30 * 60))
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsFilteredByDuration(for: 30, roomBookings: roomBookingsMapped)

      // Then
      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedRooms.filter { $0.id != "K-G6-105" })
        // swiftlint:disable:next no_direct_standard_out_logs
        print("Booking loader result: \(actualResult)")

      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms filtered by minimum 1 hour")
    func returnsRoomsFilteredByOneHourOrMore() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(
        1,
        from: Date().addingTimeInterval(70 * 60),
        to: Date().addingTimeInterval(90 * 60))
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsFilteredByDuration(for: 60, roomBookings: roomBookingsMapped)

      // Then
      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedRooms)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms filtered by minimum 2 hour")
    func returnsRoomsFilteredByTwoHoursOrMore() async {
      // Given
      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(
        1,
        from: Date().addingTimeInterval(130 * 60),
        to: Date().addingTimeInterval(150 * 60))
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = await sut.getRoomsFilteredByDuration(for: 120, roomBookings: roomBookingsMapped)

      // Then
      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedRooms)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }
  }
}

/// Function to make the building SUT
func makeRoomSUT(expect rooms: [Room], for buildingId: String? = nil, throw roomError: RoomLoaderError? = nil) -> RoomInteractor {
  let locationManager = MockLocationManager()
  let locationService = LiveLocationService(locationManager: locationManager)

  let mockLoader = MockRoomLoader()
  if roomError != nil {
    mockLoader.stubError(roomError!)
  } else if buildingId != nil {
    mockLoader.stubRooms(rooms, for: buildingId!)
  } else {
    mockLoader.stubRooms(rooms)
  }

  let remoteBookingLoader = MockRemoteRoomBookingLoader()
  let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: remoteBookingLoader)
  let roomService = LiveRoomService(roomLoader: mockLoader, roomBookingLoader: roomBookingLoader)

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
