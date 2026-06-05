//
//  LiveGraphQLBuildingLoaderTests.swift
//  Buildings
//
//  Created by Matthew Yuen on 3/6/2026.
//

import Apollo
import BuildingModels
import BuildingServices
import DevSocAPI
import Foundation
import NetworkingTestUtils
import RoomModels
import RoomServices
import Testing

// MARK: - LiveGraphQLBuildingLoaderTests

@Suite
struct LiveGraphQLBuildingLoaderTests {

  // MARK: Lifecycle

  init() {
    dataSource = MockApolloDataSource()
    stubRoomStatusLoader = StubRoomStatusLoader()
    stubBuildingRatingLoader = StubBuildingRatingLoader()

    loader = LiveGraphQLBuildingLoader(
      client: dataSource.client,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)
  }

  // MARK: Internal

  @Suite
  struct BuildingFromGraphQLTests {

    // MARK: Lifecycle

    init() {
      dataSource = MockApolloDataSource()
    }

    // MARK: Internal

    let dataSource: MockApolloDataSource

    @Test(arguments: [
      [testBuilding],
      createRealBuildings().filter(\.aliases.isEmpty),
    ])
    func `Can round trip building data`(_ buildings: [Building]) async throws {
      try await dataSource.setAllBuildingsResponse(to: buildings)

      // Preform fetch
      let fetchResponse = try await dataSource.client.fetch(query: AllBuildingsQuery())

      // Get buildings
      let graphQLBuildings = try #require(fetchResponse.data?.buildings, "Expected response data")
      // Check if the buildings are the same
      let returnedBuildings = graphQLBuildings.map(Building.init(from:))
      #expect(Set(returnedBuildings) == Set(buildings))
    }

  }

  nonisolated static let testBuilding = Building(
    name: "John Building",
    id: "building-id",
    latitude: 0.0,
    longitude: 0.0,
    aliases: [])

  let dataSource: MockApolloDataSource
  let stubRoomStatusLoader: StubRoomStatusLoader
  let stubBuildingRatingLoader: StubBuildingRatingLoader
  let loader: LiveGraphQLBuildingLoader

  @Test(arguments: [
    [testBuilding],
    createRealBuildings().filter(\.aliases.isEmpty),
  ])
  func `Can get buildings`(_ buildings: [Building]) async throws {
    let allBuildingRating = 5.0

    // Set a random room status for each building
    var roomStatusMap: [String: BuildingRoomStatus] = [:]
    roomStatusMap.reserveCapacity(buildings.count)
    for building in buildings {
      roomStatusMap[building.id] = .random()
    }

    // Set the response for the AllBuildings query
    try await dataSource.setAllBuildingsResponse(to: buildings)
    // For this test, make all the buildings have the same rating
    stubBuildingRatingLoader.fetchReturnValue = .success(allBuildingRating)
    // Set the generated room statuses as the response
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .success(roomStatusMap)

    // Fetch buildings using the loader
    let returnedBuildings = try await loader.fetch().get()

    // Make sure resules match what we expect
    for returnedBuilding in returnedBuildings {
      let expectedRoomStatus = try #require(roomStatusMap[returnedBuilding.id])
      #expect(expectedRoomStatus.numAvailable == returnedBuilding.numberOfAvailableRooms)
    }
  }

}

extension MockApolloDataSource {

  func setAllBuildingsResponse(to buildings: some Collection<Building>) async throws {
    var buildingDicts: [[String: String]] = []
    buildingDicts.reserveCapacity(buildings.count)

    // Turn each building into a Dictionary
    for building in buildings {
      buildingDicts.append([
        "__typename": "building", // Should be fine?
        "id": building.id,
        "name": building.name,
        "lat": String(building.latitude),
        "long": String(building.longitude),
      ])
    }

    let json: [String: Any] = [
      "data": [
        "buildings": buildingDicts,
      ],
    ]

    // Turn the body into Data
    let jsonData = try JSONSerialization.data(withJSONObject: json)
    // Create a success response
    let response = HTTPURLResponse(
      url: endpoint,
      statusCode: 200,
      httpVersion: nil,
      headerFields: nil)!

    // Set the new response on the session
    await session.setResponse(response, data: jsonData, for: AllBuildingsQuery.self)
  }

}

extension BuildingRoomStatus {

  static func random(
    roomStatuses: [String: RoomStatus] = [:])
    -> BuildingRoomStatus
  {
    var generator = SystemRandomNumberGenerator()
    return .random(roomStatuses: roomStatuses, using: &generator)
  }

  static func random(
    roomStatuses: [String: RoomStatus] = [:],
    using generator: inout some RandomNumberGenerator)
    -> BuildingRoomStatus
  {
    BuildingRoomStatus(
      numAvailable: Int.random(in: 0...1_000, using: &generator),
      roomStatuses: roomStatuses)
  }

}
