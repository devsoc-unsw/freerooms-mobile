//
//  BuildingSortTests.swift
//  Buildings
//
//  Created by Matthew Yuen on 19/9/2026.
//

import Testing
import Location
import CoreLocation
@testable import BuildingModels

@Suite
struct BuildingSortTests {
  
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
  
  @Test("Empty options does not change order", arguments: [
    Building.SortOptions(),
    [],
    Building.SortOptions(from: [])
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
    Building.SortOptions(from: [.reverseAlphabetical]),
    [.reverseAlphabetical],
    .reverseAlphabetical,
    Building.SortOptions(.reverseAlphabetical),
  ])
  func test_canSortByName_reverse(_ options: Building.SortOptions) {
    let buildings = Self.testBuildings.shuffled()
    let resultIDs = options.sort(buildings).map(\.id)
    #expect(resultIDs == ["ALICE", "JANE", "JOE", "JOHN"].reversed())
  }
  
  @Test("Can sort by distance", arguments: [
    Building.SortOptions(from: [.nearest(.init(latitude: 0, longitude: 0)), .alphabetical]),
    [.nearest(.init(latitude: 0, longitude: 0)), .alphabetical]
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
