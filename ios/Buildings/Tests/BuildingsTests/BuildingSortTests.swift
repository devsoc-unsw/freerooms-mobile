//
//  BuildingSortTests.swift
//  Buildings
//
//  Created by Matthew Yuen on 19/9/2026.
//

import CoreLocation
import Location
import Testing
@testable import BuildingModels

@Suite
struct BuildingSortTests {

  @Suite
  struct SortOptionsTests {

    static var identicalSortOptions0: [Building.SortOptions] {
      [
        [.alphabetical, .campus, .mostAvailable.reversed()],
        Building.SortOptions(from: [.alphabetical, .campus, .mostAvailable.reversed()]),
      ]
    }

    @Test("Identical sort options are equal", arguments: identicalSortOptions0, identicalSortOptions0)
    func test_identicalSortOptionsAreEqual(_ lhs: Building.SortOptions, _ rhs: Building.SortOptions) {
      #expect(lhs == rhs)
    }

  }

  @Suite
  struct SerializationTests {
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()

    @Test("Can round trip sort options", arguments: testSortOptions)
    func test_canRoundTripSortOptions(_ sortOptions: Building.SortOptions) throws {
      let data = try Self.encoder.encode(sortOptions)
      let decoded = try Self.decoder.decode(Building.SortOptions.self, from: data)
      #expect(decoded == sortOptions)
    }

  }

  static var testBuildings: [Building] {
    [
      Building(
        name: "John Building",
        id: "JOHN",
        latitude: 0.0,
        longitude: 0.0,
        aliases: [],
        numberOfAvailableRooms: nil),
      Building(
        name: "Jane Building",
        id: "JANE",
        latitude: 1.0,
        longitude: 0.0,
        aliases: [],
        numberOfAvailableRooms: 1),
      Building(
        name: "Joe Building",
        id: "JOE",
        latitude: 0.0,
        longitude: 2.0,
        aliases: [],
        numberOfAvailableRooms: 2),
      Building(
        name: "Alice Building",
        id: "ALICE",
        latitude: 1.0,
        longitude: 1.0,
        aliases: [],
        numberOfAvailableRooms: 3),
    ]
  }

  static var testSortOptions: [Building.SortOptions] {
    [
      .init(from: [.alphabetical]),
      .alphabetical,
      .alphabetical.reversed(),
      .campus,
      .campus.reversed(),
      [.alphabetical, .mostAvailable],
      .mostAvailable.reversed().reversed().reversed(),
      ([.campus, .alphabetical.reversed()] as Building.SortOptions).reversed(),
    ]
  }

  @Test("Empty options does not change order", arguments: [
    Building.SortOptions(),
    [],
    Building.SortOptions(from: []),
  ])
  func test_emptyOptionsDoesNotChangeOrder(_ options: Building.SortOptions) {
    let buildings = Self.testBuildings
    #expect(options.sort(buildings) == buildings)
  }

  @Test("Can sort by name (alphabetical)", arguments: [
    Building.SortOptions(from: [.alphabetical]),
    [.alphabetical],
    .alphabetical,
    Building.SortOptions(.alphabetical),
  ])
  func test_canSortByName_alphabetical(_ options: Building.SortOptions) {
    let buildings = Self.testBuildings.shuffled()
    let resultIDs = options.sort(buildings).map(\.id)
    #expect(resultIDs == ["ALICE", "JANE", "JOE", "JOHN"])
  }

  @Test("Can sort by name (reverse)", arguments: [
    Building.SortOptions(from: [.alphabetical.reversed()]),
    [.alphabetical.reversed()],
    .alphabetical.reversed(),
    Building.SortOptions(.alphabetical.reversed()),
  ])
  func test_canSortByName_reverse(_ options: Building.SortOptions) {
    let buildings = Self.testBuildings.shuffled()
    let resultIDs = options.sort(buildings).map(\.id)
    #expect(resultIDs == ["ALICE", "JANE", "JOE", "JOHN"].reversed())
  }

  @Test("Can sort by distance", arguments: [
    Building.SortOptions(from: [.nearest(to: .init(latitude: 0, longitude: 0)), .alphabetical]),
    [.nearest(to: .init(latitude: 0, longitude: 0)), .alphabetical]
  ])
  func test_canSortByDistance(_ options: Building.SortOptions) {
    let buildings = Self.testBuildings.shuffled()
    let resultIDs = options.sort(buildings).map(\.id)
    #expect(resultIDs == ["JOHN", "JANE", "ALICE", "JOE"])
  }

  @Test("Can sort by available rooms", arguments: [
    Building.SortOptions(from: [.mostAvailable]),
    [.mostAvailable],
    .mostAvailable,
    Building.SortOptions(.mostAvailable),
  ])
  func test_canSortByAvailableRooms(_ options: Building.SortOptions) {
    let buildings = Self.testBuildings.shuffled()
    let resultIDs = options.sort(buildings).map(\.id)
    #expect(resultIDs == ["ALICE", "JOE", "JANE", "JOHN"])
  }

}
