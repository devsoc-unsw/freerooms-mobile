//
//  JSONLoaderTests.swift
//  Persistence
//
//  Created by Chris Wong on 22/6/2025.
//

import Testing
@testable import Persistence
@testable import PersistenceTestUtils

// MARK: - JSONLoaderTests

struct JSONLoaderTests {

  // MARK: Internal

  @Test("JSON loader decodes json file into platform type [DecodableBuildings]")
  func loadsBuildingsFromJSONFile() async {
    // Given
    let mockFileLoader = MockFileLoader(loads: fakeBuildingsJSON)
    let sut = LiveJSONLoader<[DecodableBuilding]>(using: mockFileLoader)

    // When
    let res = await sut.load(from: "fakeFilePath/fake")

    // Then
    let decodableBuildings = createDecodableBuildings(2)
    expect(res, toFetch: decodableBuildings)
  }

  @Test("Throws an error when file does not exist")
  func throwsErrorOnFileNotExisting() async {
    // Given
    let mockFileLoader = MockFileLoader(throws: FileLoaderError.fileNotFound)
    let sut = LiveJSONLoader<[DecodableBuilding]>(using: mockFileLoader)

    // When
    let res = await sut.load(from: "fakeFilePath/fake")

    // Then
    expect(res, toThrow: .fileNotFound)
  }

  @Test("Throws an error when JSON in file is malformed")
  func throwsErrorOnMalformedJSON() async {
    // Given
    let mockFileLoader = MockFileLoader(loads: fakeBuildingsMalformedJSON)
    let sut = LiveJSONLoader<[DecodableBuilding]>(using: mockFileLoader)

    // When
    let res = await sut.load(from: "fakeFilePath/fake")

    // Then
    expect(res, toThrow: .malformedJSON)
  }

  @Test("JSON Loader decodes empty buildings json file into empty platform type [DecodableBuilding]")
  func loadsEmptyArrayFromEmptyJSONFile() async {
    // Given
    let mockFileLoader = MockFileLoader(loads: emptyJSON)
    let sut = LiveJSONLoader<[DecodableBuilding]>(using: mockFileLoader)

    // When
    let res = await sut.load(from: "fakeFilePath/fake")

    // Then
    let emptyDecodeableBuildings = [DecodableBuilding]()
    expect(res, toFetch: emptyDecodeableBuildings)
  }

  @Test("JSON Loader successfully decodes buildings seed JSON")
  func loadsJSONFromFakeBuildingsSeedJSONSuccessfully() async throws {
    // Given
    let mockFileLoader = MockFileLoader(loads: fakeBuildingsSeedJSON)
    let sut = LiveJSONLoader<[DecodableBuilding]>(using: mockFileLoader)

    // When
    let res = await sut.load(from: "fakeFilePath/fake")

    // Then
    let decodableBuildings = createDecodableBuildings(2)
    expect(res, toFetch: decodableBuildings)
  }

  // MARK: Private

  private func expect(_ res: LiveJSONLoader<[DecodableBuilding]>.Result, toThrow expected: JSONLoaderError) {
    switch res {
    case .failure(let error):
      #expect(error == expected)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: LiveJSONLoader<[DecodableBuilding]>.Result, toFetch expected: [DecodableBuilding]) {
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

}

private let fakeBuildingsJSON = """
  [
        {
          "aliases": ["A", "B"],
          "id": "123",
          "lat": 1.0,
          "name": "name",
          "long": 1.0
        },
        {
          "aliases": ["A", "B"],
          "id": "123",
          "lat": 1.0,
          "name": "name",
          "long": 1.0
        }
  ]
  """

private let fakeBuildingsMalformedJSON = """
   "buil [
        {
          "aliases": ["A", "B"],
          "id": "123",
          "lat": 1.0,
          "name": "name",
          "long": 1.0
        },
        {
          "aliases": ["A", "B"],
          "id": "123",
          "lat": 1.0,
          "name": "name",
          "long": 1.0
        }
  ]
  """

private let emptyJSON = """
  []
  """

private let fakeBuildingsSeedJSON = """
  [
    {
      "aliases": ["A", "B"],
      "id": "123",
      "lat": 1.0,
      "name": "name",
      "long": 1.0
    },
    {
      "aliases": ["A", "B"],
      "id": "123",
      "lat": 1.0,
      "name": "name",
      "long": 1.0
    }
  ]
  """

// MARK: - DecodableBuilding

private nonisolated
struct DecodableBuilding: Decodable, Equatable {
  public let name: String
  public let id: String
  public let lat: Double
  public let long: Double
  public let aliases: [String]

  public init(name: String, id: String, lat: Double, long: Double, aliases: [String]) {
    self.name = name
    self.id = id
    self.lat = lat
    self.long = long
    self.aliases = aliases
  }
}
