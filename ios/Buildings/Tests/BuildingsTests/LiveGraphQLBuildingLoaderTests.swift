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
import Testing

@Suite
struct LiveGraphQLBuildingLoaderTests {

  // MARK: Lifecycle

  init() {
    let endpoint = URL(string: "https://api.example.com/graphql")!
    let session = MockApolloURLSession()
    let store = ApolloStore()

    let transport = RequestChainNetworkTransport(
      urlSession: session,
      interceptorProvider: DefaultInterceptorProvider.shared,
      store: store,
      endpointURL: endpoint)

    let client = ApolloClient(
      networkTransport: transport,
      store: store)

    self.endpoint = endpoint
    self.session = session
    self.client = client
  }

  // MARK: Internal

  let endpoint: URL
  let session: MockApolloURLSession
  let client: ApolloClient

  func createResponse(
    for buildings: some Collection<Building>)
    throws -> (Data, URLResponse)
  {
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

    return (jsonData, response)
  }

  @Test(arguments: [
    [
      Building(
        name: "John Building",
        id: "building-id",
        latitude: 0.0,
        longitude: 0.0,
        aliases: []),
    ],
    createRealBuildings()
  ])
  func `Loader can load buildings`(_ buildings: [Building]) async throws {

    let (data, response) = try createResponse(for: buildings)

    // Set the next session response
    await session.setResponse(response, data: data, for: AllBuildingsQuery.self)
    // Preform fetch
    let fetchResponse = try await client.fetch(query: AllBuildingsQuery())

    // Get buildings
    let graphQLBuildings = try #require(fetchResponse.data?.buildings, "Expected response data")
    // Check if the buildings are the same
    let returnedBuildings = graphQLBuildings.map(Building.init(from:))
    #expect(Set(returnedBuildings) == Set(buildings))
  }
}
