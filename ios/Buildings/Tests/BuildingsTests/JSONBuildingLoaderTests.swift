//
//  JSONBuildingLoaderTests.swift
//  Persistence
//
//  Created by Chris Wong on 30/6/2025.
//

import BuildingModels
import Testing
@testable import BuildingServices
@testable import Persistence
@testable import PersistenceTestUtils

struct JSONBuildingLoaderTests {

  // MARK: Internal

  @Test("Check buildings bundle string exists")
  func checkBuildingsBundleStringExists() async throws {
    let decodableBuildings = createDecodableBuildings(0)
    let mockJSONLoader = MockJSONLoader<[DecodableBuilding]>(loads: decodableBuildings)
    let JSONBuildingLoader = LiveJSONBuildingLoader(using: mockJSONLoader)
    if JSONBuildingLoader.buildingsSeedJSONPath == nil {
      Issue.record("Buildings Seed JSON not found in bundle")
    }
  }

  @Test("Live JSON building loader successfully decodes JSON into type [Building]")
  func liveJSONBuildingLoaderSuccessfullyDecodesJSON() async {
    // Given
    let decodableBuildings = createDecodableBuildings(10)
    let mockJSONLoader = MockJSONLoader<[DecodableBuilding]>(loads: decodableBuildings)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = await sut.fetch()

    // Then
    let buildings = createBuildings(10)
    expect(res, toFetch: buildings)
  }

  @Test("Live JSON building loader successfully decodes empty JSON into type [Building]")
  func liveJSONBuildingLoaderSuccessfullyDecodesEmptyJSON() async {
    // Given
    let decodableBuildings = createDecodableBuildings(0)
    let mockJSONLoader = MockJSONLoader<[DecodableBuilding]>(loads: decodableBuildings)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = await sut.fetch()

    // Then
    let buildings = [Building]()
    expect(res, toFetch: buildings)
  }

  @Test("Live JSON building loader returns error when JSON loader cannot find file")
  func liveJSONBuildingLoaderThrowsErrorOnNoFileFound() async {
    // Given
    let mockJSONLoader = MockJSONLoader<[DecodableBuilding]>(throws: JSONLoaderError.fileNotFound)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toThrow: .fileNotFound)
  }

  @Test("Live JSON building loader returns error when JSON loader cannot read malformed JSON")
  func liveJSONBuildingLoaderThrowsErrorOnMalformedJson() async {
    // Given
    let mockJSONLoader = MockJSONLoader<[DecodableBuilding]>(throws: JSONLoaderError.malformedJSON)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toThrow: .malformedJSON)
  }

  @Test("Live JSON building loader integration with Live JSON loader successfully loads buildings from JSON file")
  func liveJSONBuildingLoaderIntegratesWithLiveJSONLoaderSuccessfully() async throws {
    // Given
    let realBuildingsData = createRealBuildings()
    let liveFileLoader = LiveFileLoader()
    let liveJSONLoader = LiveJSONLoader<[DecodableBuilding]>(using: liveFileLoader)
    let liveJSONBuildingLoader = LiveJSONBuildingLoader(using: liveJSONLoader)

    // When
    let res = await liveJSONBuildingLoader.fetch()

    // Then
    expect(res, toFetch: realBuildingsData)
  }

  // MARK: Private

  private func expect(_ res: LiveJSONBuildingLoader.Result, toThrow expected: BuildingLoaderError) {
    switch res {
    case .failure(let error):
      #expect(error == expected)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: LiveJSONBuildingLoader.Result, toFetch expected: [Building]) {
    switch res {
    case .success(let buildings):
      #expect(buildings == expected)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

  private func createDecodableBuildings(_ count: Int) -> [DecodableBuilding] {
    var decodableBuildings = [DecodableBuilding]()
    for _ in 0..<count {
      decodableBuildings.append(DecodableBuilding(name: "name", id: "123", lat: 1.0, long: 1.0, aliases: ["A", "B"]))
    }
    return decodableBuildings
  }

  private func createBuildings(_ count: Int) -> [Building] {
    var buildings = [Building]()
    for _ in 0..<count {
      buildings.append(Building(name: "name", id: "123", latitude: 1.0, longitude: 1.0, aliases: ["A", "B"]))
    }
    return buildings
  }

}
