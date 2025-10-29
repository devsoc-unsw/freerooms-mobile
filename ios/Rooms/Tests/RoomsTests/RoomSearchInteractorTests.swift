//
//  RoomSearchInteractorTests.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 25/9/2025.
//

import Foundation
import Location
import RoomModels
import Testing

@testable import RoomInteractors
@testable import RoomServices
@testable import RoomTestUtils

// MARK: - RoomSearchInteractorTests

enum RoomSearchInteractorTests {
  struct RoomStringFiltering {
    @Test("Returns all rooms when filter string is empty")
    func returnsAllRoomsWhenFilterStringIsEmpty() async {
      // Given
      let expectedRooms = createRoomsWithDifferentNames()
      let sut = makeRoomSearchSUT(expect: expectedRooms)

      // When
      let result = await sut.filterRooms(by: "")

      // Then
      let expectedSorted = sortRoomsByNameAscending(expectedRooms)
      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedSorted)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms that contain the given string")
    func returnsRoomsThatContainGivenString() async {
      // Given
      let expectedRooms = createRoomsWithDifferentNames()
      let sut = makeRoomSearchSUT(expect: expectedRooms)

      // When
      let result = await sut.filterRooms(by: "Colombo")

      // Then
      let expectedFilteredRooms = sortRoomsByNameAscending(expectedRooms.filter { $0.name.contains("Colombo") })

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedFilteredRooms)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns empty array when no rooms contain the given string")
    func returnsEmptyArrayWhenNoRoomsContainGivenString() async {
      // Given
      let expectedRooms = createRoomsWithDifferentNames()
      let sut = makeRoomSearchSUT(expect: expectedRooms)

      // When
      let result = await sut.filterRooms(by: "NonExistent")

      // Then
      switch result {
      case .success(let actualResult):
        #expect(actualResult.isEmpty)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms case-insensitively when filtering")
    func returnsRoomsCaseInsensitivelyWhenFiltering() async {
      // Given
      let expectedRooms = createRoomsWithDifferentNames()
      let sut = makeRoomSearchSUT(expect: expectedRooms)

      // When
      let result = await sut.filterRooms(by: "colombo")

      // Then
      let expectedFilteredRooms = sortRoomsByNameAscending(expectedRooms.filter { $0.name.lowercased().contains("colombo") })

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedFilteredRooms)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms that contain substring in the middle of the name")
    func returnsRoomsThatContainSubstringInMiddleOfName() async {
      // Given
      let expectedRooms = createRoomsWithDifferentNames()
      let sut = makeRoomSearchSUT(expect: expectedRooms)

      // When
      let result = await sut.filterRooms(by: "LG")

      // Then
      let expectedFilteredRooms = sortRoomsByNameAscending(expectedRooms.filter { $0.name.contains("LG") })

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedFilteredRooms)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms that contain substring at the end of the name")
    func returnsRoomsThatContainSubstringAtEndOfName() async {
      // Given
      let expectedRooms = createRoomsWithDifferentNames()
      let sut = makeRoomSearchSUT(expect: expectedRooms)

      // When
      let result = await sut.filterRooms(by: "101")

      // Then
      let expectedFilteredRooms = sortRoomsByNameAscending(expectedRooms.filter { $0.name.contains("101") })

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedFilteredRooms)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }

    @Test("Returns rooms with partial word matching")
    func returnsRoomsWithPartialWordMatching() async {
      // Given
      let expectedRooms = createRoomsWithDifferentNames()
      let sut = makeRoomSearchSUT(expect: expectedRooms)

      // When
      let result = await sut.filterRooms(by: "Math")

      // Then
      let expectedFilteredRooms = sortRoomsByNameAscending(expectedRooms.filter { $0.name.contains("Math") })

      switch result {
      case .success(let actualResult):
        #expect(actualResult == expectedFilteredRooms)
      case .failure:
        Issue.record("Expected success, got failure")
      }
    }
  }
}

// MARK: - RoomSearchAdapter

/// Adapter that mimics the old RoomSearchInteractor using RoomInteractor
struct RoomSearchAdapter {
  let interactor: RoomInteractor

  func filterRooms(by searchString: String) async -> Result<[Room], Error> {
    switch await interactor.getRoomsSortedAlphabetically(inAscendingOrder: true) {
    case .success(let rooms):
      let filtered = interactor.filterRoomsByQueryString(rooms, by: searchString)
      return .success(filtered)

    case .failure(let error):
      return .failure(error)
    }
  }
}

/// Function to make the room search SUT using RoomInteractor
func makeRoomSearchSUT(expect rooms: [Room]) -> RoomSearchAdapter {
  let mockLoader = MockRoomLoader()
  mockLoader.stubRooms(rooms)

  let roomService = LiveRoomService(roomLoader: mockLoader)
  let interactor = RoomInteractor(
    roomService: roomService,
    locationService: LiveLocationService(locationManager: LiveLocationManager()))

  return RoomSearchAdapter(interactor: interactor)
}

/// Create rooms with different names for testing
func createRoomsWithDifferentNames() -> [Room] {
  [
    Room(
      abbreviation: "Col LG01",
      accessibility: [],
      audioVisual: [],
      buildingId: "K-B16",
      capacity: 48,
      floor: "LG",
      id: "K-B16-LG01",
      infoTechnology: [],
      latitude: -33.916155183912196,
      longitude: 151.23130187740358,
      microphone: [],
      name: "Colombo LG01",
      school: "UNSW",
      seating: "Movable",
      usage: "TUSM",
      service: [],
      writingMedia: []),
    Room(
      abbreviation: "Col LG02",
      accessibility: [],
      audioVisual: [],
      buildingId: "K-B16",
      capacity: 56,
      floor: "LG",
      id: "K-B16-LG02",
      infoTechnology: [],
      latitude: -33.91602605723141,
      longitude: 151.2313272230597,
      microphone: [],
      name: "Colombo LG02",
      school: "UNSW",
      seating: "Movable",
      usage: "TUSM",
      service: [],
      writingMedia: []),
    Room(
      abbreviation: "Block 105",
      accessibility: [],
      audioVisual: [],
      buildingId: "K-G6",
      capacity: 20,
      floor: "1",
      id: "K-G6-105",
      infoTechnology: [],
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
      abbreviation: "Math 101",
      accessibility: [],
      audioVisual: [],
      buildingId: "K-F23",
      capacity: 30,
      floor: "1",
      id: "K-F23-101",
      infoTechnology: [],
      latitude: -33.918793948030846,
      longitude: 151.23134411127646,
      microphone: [],
      name: "Mathematics 101",
      school: "UNSW",
      seating: "Fixed",
      usage: "LCTR",
      service: [],
      writingMedia: []),
  ]
}

/// Helpers
func sortRoomsByNameAscending(_ rooms: [Room]) -> [Room] {
  rooms.sorted { $0.name < $1.name }
}
