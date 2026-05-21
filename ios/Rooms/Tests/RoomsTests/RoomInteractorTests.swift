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

  struct GetFilteredRooms {
    @Test("Returns the rooms whose ids match the backend response")
    func returnsRoomsWhoseIdsMatchBackend() async {
      // Given
      let allRooms = createDifferentRooms()
      let matchingIds = ["K-G6-105", "K-H20-101"]
      let sut = makeRoomSUT(
        allRooms: allRooms,
        filterResult: .success(matchingIds))

      // When
      let result = await sut.getFilteredRooms(options: FilterRoomOptions())

      // Then
      switch result {
      case .success(let actualResult):
        #expect(Set(actualResult.map(\.id)) == Set(matchingIds))
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns empty array when backend returns no matching ids")
    func returnsEmptyWhenBackendReturnsNoIds() async {
      // Given
      let allRooms = createDifferentRooms()
      let sut = makeRoomSUT(
        allRooms: allRooms,
        filterResult: .success([]))

      // When
      let result = await sut.getFilteredRooms(options: FilterRoomOptions())

      // Then
      switch result {
      case .success(let actualResult):
        #expect(actualResult.isEmpty)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns connectivity error when backend fails")
    func returnsConnectivityErrorWhenBackendFails() async {
      // Given
      let allRooms = createDifferentRooms()
      let sut = makeRoomSUT(
        allRooms: allRooms,
        filterResult: .failure(.connectivity))

      // When
      let result = await sut.getFilteredRooms(options: FilterRoomOptions())

      // Then
      switch result {
      case .success:
        Issue.record("Expected failure, got success")
      case .failure(let error):
        #expect(error == .connectivity)
      }
    }
  }

  struct ApplyClientSideFilters {
    @Test("Returns all rooms unchanged when campusLocation is nil")
    func returnsAllRoomsWhenCampusLocationIsNil() {
      // Given
      let allRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: allRooms)

      // When
      let result = sut.applyClientSideFilters(rooms: allRooms, campusLocation: nil)

      // Then
      #expect(result == allRooms)
    }

    @Test("Keeps only lower-campus rooms when CampusLocation.lower is selected")
    func keepsOnlyLowerCampusRooms() {
      // Given
      let allRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: allRooms)

      // When
      let result = sut.applyClientSideFilters(rooms: allRooms, campusLocation: .lower)

      // Then
      #expect(result.count == 1)
      #expect(result.first?.abbreviation == "Block 105")
    }

    @Test("Keeps only middle-campus rooms when CampusLocation.middle is selected")
    func keepsOnlyMiddleCampusRooms() {
      // Given
      let allRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: allRooms)

      // When
      let result = sut.applyClientSideFilters(rooms: allRooms, campusLocation: .middle)

      // Then
      #expect(result.count == 1)
      #expect(result.first?.abbreviation == "Ainswth501")
    }

    @Test("Keeps only upper-campus rooms when CampusLocation.upper is selected")
    func keepsOnlyUpperCampusRooms() {
      // Given
      let allRooms = createDifferentRooms()
      let sut = makeRoomSUT(expect: allRooms)

      // When
      let result = sut.applyClientSideFilters(rooms: allRooms, campusLocation: .upper)

      // Then
      #expect(result.count == 2)
      #expect(result.allSatisfy { $0.buildingId == "K-H20" })
    }
  }

  struct FilterRoomOptionsMapping {
    @Test("Maps the selected date to an ISO8601 dateTime string with fractional seconds")
    func mapsSelectedDateToISO8601WithFractionalSeconds() {
      // Given
      let date = Date(timeIntervalSince1970: 1_700_000_000)
      let expectedFormatter = ISO8601DateFormatter()
      expectedFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

      // When
      let options = FilterRoomOptions.make(
        selectedDate: date,
        selectedRoomTypes: [],
        selectedDuration: nil,
        selectedCapacity: nil)

      // Then
      // The backend rejects ISO timestamps without fractional seconds (HTTP 400),
      // so this format is required, not cosmetic.
      #expect(options.dateTime == expectedFormatter.string(from: date))
      #expect(options.dateTime?.contains(".") == true)
    }

    @Test("Maps a single selected room type to the corresponding usage code")
    func mapsSingleRoomTypeToUsage() {
      // When
      let options = FilterRoomOptions.make(
        selectedDate: Date(),
        selectedRoomTypes: [.auditorium],
        selectedDuration: nil,
        selectedCapacity: nil)

      // Then
      #expect(options.usage == RoomType.auditorium.rawValue)
    }

    @Test("Maps multiple selected room types to nil usage (fallback)")
    func mapsMultipleRoomTypesToNilUsage() {
      // When
      let options = FilterRoomOptions.make(
        selectedDate: Date(),
        selectedRoomTypes: [.auditorium, .lectureHall],
        selectedDuration: nil,
        selectedCapacity: nil)

      // Then
      #expect(options.usage == nil)
    }

    @Test("Maps empty selected room types to nil usage")
    func mapsEmptyRoomTypesToNilUsage() {
      // When
      let options = FilterRoomOptions.make(
        selectedDate: Date(),
        selectedRoomTypes: [],
        selectedDuration: nil,
        selectedCapacity: nil)

      // Then
      #expect(options.usage == nil)
    }

    @Test("Maps selected duration to its raw int value")
    func mapsDurationToRawInt() {
      // When
      let options = FilterRoomOptions.make(
        selectedDate: Date(),
        selectedRoomTypes: [],
        selectedDuration: .oneHour,
        selectedCapacity: nil)

      // Then
      #expect(options.duration == Duration.oneHour.rawValue)
    }

    @Test("Maps selected capacity directly")
    func mapsCapacityDirectly() {
      // When
      let options = FilterRoomOptions.make(
        selectedDate: Date(),
        selectedRoomTypes: [],
        selectedDuration: nil,
        selectedCapacity: 25)

      // Then
      #expect(options.capacity == 25)
    }

    @Test("Leaves CampusLocation-related fields unset (filtered client-side)")
    func leavesLocationUnset() {
      // When
      let options = FilterRoomOptions.make(
        selectedDate: Date(),
        selectedRoomTypes: [],
        selectedDuration: nil,
        selectedCapacity: nil)

      // Then
      #expect(options.location == nil)
      #expect(options.buildingId == nil)
      #expect(options.startTime == nil)
      #expect(options.endTime == nil)
      #expect(options.sortedBySpecificSchoolId == false)
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
    roomRatingLoader: StubRoomRatingLoader(),
    roomFilterService: StubFilterRoomService())

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
    roomRatingLoader: StubRoomRatingLoader(),
    roomFilterService: StubFilterRoomService())
  return RoomInteractor(roomService: roomService, locationService: locationService)
}

/// SUT for the backend-filtered path: configures both the room loader (full
/// catalogue) and the filter service (matching ids returned by the API).
func makeRoomSUT(
  allRooms: [Room],
  filterResult: Result<[String], FilterRoomServiceError>)
  -> RoomInteractor
{
  let spyLocationManager = SpyLocationManager()
  let locationService = LiveLocationService(locationManager: spyLocationManager)

  let stubLoader = StubRoomLoader()
  stubLoader.fetchReturnValue = .success(allRooms)

  let stubFilterService = StubFilterRoomService()
  stubFilterService.fetchFilteredRoomsReturnValue = filterResult

  let stubRemoteBookingLoader = StubRemoteRoomBookingLoader()
  let roomBookingLoader = LiveRoomBookingLoader(remoteRoomBookingLoader: stubRemoteBookingLoader)
  let roomService = LiveRoomService(
    roomLoader: stubLoader,
    roomBookingLoader: roomBookingLoader,
    roomRatingLoader: StubRoomRatingLoader(),
    roomFilterService: stubFilterService)

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
