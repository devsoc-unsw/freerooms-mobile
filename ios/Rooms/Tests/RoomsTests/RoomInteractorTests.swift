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
      let result = await sut.getRoomsFilteredAlphabeticallyByBuildingId(
        buildingId: "K-H20", inAscendingOrder: true)

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
      let result = await sut.getRoomsFilteredAlphabeticallyByBuildingId(
        buildingId: "K-P20", inAscendingOrder: true)

      // Then
      let expectResult =
        expectedRooms
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

      // When
      let result = await sut.getRoomsFilteredByAllBuildingId()

      // Then
      var expectResult = [String: [Room]]()
      for room in expectedRooms {
        expectResult[room.buildingId, default: []].append(room)
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
      let now = Date()
      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(
        1,
        from: now.addingTimeInterval(40 * 60),
        to: now.addingTimeInterval(60 * 60))
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByDuration(
        for: 30,
        roomBookings: roomBookingsMapped,
        rooms: expectedRooms,
        now: now)

      // Then
      #expect(result == expectedRooms)
    }

    @Test("Returns rooms filtered by minimum 30 minutes with one room booked during current time")
    func returnsRoomsFilteredBy30MinutesOrMorDuringCurrentTime() async {
      // Given
      let now = Date()
      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(
        1,
        from: now,
        to: now.addingTimeInterval(30 * 60))
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByDuration(
        for: 30,
        roomBookings: roomBookingsMapped,
        rooms: expectedRooms,
        now: now)

      // Then
      #expect(result == expectedRooms.filter { $0.id != "K-G6-105" })
    }

    @Test("Returns rooms filtered by minimum 1 hour")
    func returnsRoomsFilteredByOneHourOrMore() async {
      // Given
      let now = Date()
      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(
        1,
        from: now.addingTimeInterval(70 * 60),
        to: now.addingTimeInterval(90 * 60))
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByDuration(
        for: 60,
        roomBookings: roomBookingsMapped,
        rooms: expectedRooms,
        now: now)

      // Then
      #expect(result == expectedRooms)
    }

    @Test("Returns rooms filtered by minimum 2 hour")
    func returnsRoomsFilteredByTwoHoursOrMore() async {
      // Given
      let now = Date()
      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(
        1,
        from: now.addingTimeInterval(130 * 60),
        to: now.addingTimeInterval(150 * 60))
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      // When
      let result = sut.getRoomsFilteredByDuration(
        for: 120,
        roomBookings: roomBookingsMapped,
        rooms: expectedRooms,
        now: now)

      // Then
      #expect(result == expectedRooms)
    }

    @Test("8am with 9am booking: 30 min duration keeps all rooms available")
    func eightAmWithNineAmBookingThirtyMinIncludesAllRooms() async {
      var calendar = Calendar(identifier: .gregorian)
      calendar.timeZone = TimeZone(secondsFromGMT: 0)!
      let eightAM = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15, hour: 8, minute: 0))!
      let nineAM = calendar.date(byAdding: .hour, value: 1, to: eightAM)!
      let tenAM = calendar.date(byAdding: .hour, value: 2, to: eightAM)!

      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(1, from: nineAM, to: tenAM)
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      let result = sut.getRoomsFilteredByDuration(
        for: 30,
        roomBookings: roomBookingsMapped,
        rooms: expectedRooms,
        now: eightAM)

      #expect(result == expectedRooms)
    }

    @Test("8am with 9am booking: 90 min duration excludes booked room")
    func eightAmWithNineAmBookingNinetyMinExcludesBookedRoom() async {
      var calendar = Calendar(identifier: .gregorian)
      calendar.timeZone = TimeZone(secondsFromGMT: 0)!
      let eightAM = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15, hour: 8, minute: 0))!
      let nineAM = calendar.date(byAdding: .hour, value: 1, to: eightAM)!
      let tenAM = calendar.date(byAdding: .hour, value: 2, to: eightAM)!

      let expectedRooms = createDifferentRooms()
      let roomBookings = createRoomBookingsFromStartToEnd(1, from: nineAM, to: tenAM)
      let roomBookingsMapped: [String: [RoomBooking]] = ["K-G6-105": roomBookings]
      let sut = makeRoomSUT(expect: expectedRooms)

      let result = sut.getRoomsFilteredByDuration(
        for: 90,
        roomBookings: roomBookingsMapped,
        rooms: expectedRooms,
        now: eightAM)

      #expect(result == expectedRooms.filter { $0.id != "K-G6-105" })
    }
  }

  struct RoomFilterReferenceInstant {
    @Test("filteringReferenceInstant uses selectedDate when it differs from DateDefaults")
    func filteringReferenceInstantUsesCustomSelectedDate() {
      let savedDefault = DateDefaults.selectedDate
      defer { DateDefaults.selectedDate = savedDefault }

      let baseline = Date(timeIntervalSince1970: 1_700_000_000)
      DateDefaults.selectedDate = baseline
      let custom = baseline.addingTimeInterval(3_600)
      let filter = RoomFilter(selectedDate: custom)

      #expect(filter.filteringReferenceInstant(clockNow: Date()) == custom)
    }

    @Test("filteringReferenceInstant uses clock when selectedDate matches DateDefaults")
    func filteringReferenceInstantUsesClockWhenDateIsDefault() {
      let savedDefault = DateDefaults.selectedDate
      defer { DateDefaults.selectedDate = savedDefault }

      let baseline = Date(timeIntervalSince1970: 1_700_000_000)
      DateDefaults.selectedDate = baseline
      let clock = baseline.addingTimeInterval(123)
      let filter = RoomFilter(selectedDate: baseline)

      #expect(filter.filteringReferenceInstant(clockNow: clock) == clock)
    }
  }
}

/// Function to make the building SUT
func makeRoomSUT(
  expect rooms: [Room], for buildingId: String? = nil, throw roomError: RoomLoaderError? = nil)
  -> RoomInteractor
{
  let spyLocationManager = SpyLocationManager()
  let locationService = LiveLocationService(locationManager: spyLocationManager)

  let stubLoader = StubRoomLoader()
  if let roomError {
    stubLoader.fetchBuildingIdReturnValue = .failure(roomError)
    stubLoader.fetchReturnValue = .failure(roomError)
  } else if buildingId != nil {
    stubLoader.fetchBuildingIdReturnValue = .success(rooms)
  } else {
    stubLoader.fetchReturnValue = .success(rooms)
  }

  let stubRemoteBookingLoader = StubRemoteRoomBookingLoader()
  let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: stubRemoteBookingLoader)
  let roomService = LiveRoomService(
    roomLoader: stubLoader,
    roomBookingLoader: roomBookingLoader,
    roomRatingLoader: StubRoomRatingLoader())

  return RoomInteractor(roomService: roomService, locationService: locationService)
}

func makeRoomSUT(stubLoader: StubRoomLoader) -> RoomInteractor {
  let spyLocationManager = SpyLocationManager()
  let locationService = LiveLocationService(locationManager: spyLocationManager)
  let stubRemoteBookingLoader = StubRemoteRoomBookingLoader()
  let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: stubRemoteBookingLoader)
  let roomService = LiveRoomService(
    roomLoader: stubLoader,
    roomBookingLoader: roomBookingLoader,
    roomRatingLoader: StubRoomRatingLoader())
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
