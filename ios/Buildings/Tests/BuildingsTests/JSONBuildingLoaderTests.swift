//
//  JSONBuildingLoaderTests.swift
//  Persistence
//
//  Created by Chris Wong on 30/6/2025.
//

import Buildings
import Testing
@testable import Persistence

struct JSONBuildingLoaderTests {

  // MARK: Internal

  @Test("Live JSON building loader successfully decodes JSON into type [Building]")
  func liveJSONBuildingLoaderSuccessfullyDecodesJSON() {
    // Given
    let decodableBuildings = createDecodableBuildings(10)
    let mockJSONLoader = MockJSONLoader<[DecodableBuilding]>(loads: decodableBuildings)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = sut.decode(from: "blahblah")

    // Then
    let buildings = createBuildings(10)
    expect(res, toFetch: buildings)
  }

  @Test("Live JSON building loader successfully decodes empty JSON into type [Building]")
  func liveJSONBuildingLoaderSuccessfullyDecodesEmptyJSON() {
    // Given
    let decodableBuildings = [DecodableBuilding]()
    let mockJSONLoader = MockJSONLoader<[DecodableBuilding]>(loads: decodableBuildings)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = sut.decode(from: "blahblah")

    // Then
    let buildings = [Building]()
    expect(res, toFetch: buildings)
  }

  @Test("Live JSON building loader returns error when JSON loader cannot find file")
  func liveJSONBuildingLoaderThrowsErrorOnNoFileFound() {
    // Given
    let mockJSONLoader = MockJSONLoader<[DecodableBuilding]>(throws: JSONLoaderError.fileNotFound)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = sut.decode(from: "blahblah")

    // Then
    expect(res, toThrow: JSONLoaderError.fileNotFound)
  }

  @Test("Live JSON building loader returns error when JSON loader cannot read malformed JSON")
  func liveJSONBuildingLoaderThrowsErrorOnMalformedJson() {
    // Given
    let mockJSONLoader = MockJSONLoader<[DecodableBuilding]>(throws: JSONLoaderError.malformedJSON)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = sut.decode(from: "blahblah")

    // Then
    expect(res, toThrow: JSONLoaderError.malformedJSON)
  }

  // MARK: Private

  private func expect(_ res: LiveJSONBuildingLoader.Result, toThrow expected: JSONLoaderError) {
    switch res {
    case .failure(let error):
      if let actual = error as? JSONLoaderError, actual == expected {
        // test passed - unsure if better way here (since result uses protocol error type instead of concrete enum)
      } else {
        Issue.record("Expected \(expected), but got \(error)")
      }
      #expect(1 == 1)

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
    var decodableBuildings: [DecodableBuilding] = []
    for _ in 0..<count {
      decodableBuildings.append(DecodableBuilding(name: "name", id: "123", lat: 1.0, long: 1.0, aliases: ["A", "B"]))
    }
    return decodableBuildings
  }

  private func createBuildings(_ count: Int) -> [Building] {
    var buildings: [Building] = []
    for _ in 0..<count {
      buildings.append(Building(name: "name", id: "123", latitude: 1.0, longitude: 1.0, aliases: ["A", "B"]))
    }
    return buildings
  }
}
