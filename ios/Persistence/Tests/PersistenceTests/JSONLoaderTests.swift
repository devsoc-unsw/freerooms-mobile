//
//  JSONLoaderTests.swift
//  Persistence
//
//  Created by Chris Wong on 22/6/2025.
//

import Buildings
import Testing
@testable import Persistence

struct JSONLoaderTests {

  // MARK: Internal

  @Test("JSON loader decodes json file into platform type [PlatformBuildings]")
  func loadsBuildingsFromJSONFile() {
    // Given
    let mockFileLoader = MockFileLoader(loads: fakeBuildingsJSON)
    let sut = LiveJSONLoader<[PlatformBuilding]>(using: mockFileLoader)

    // When
    let res = sut.load(from: "fakeFilePath/fake")

    // Then
    let platformBuildings = createPlatformBuildings(2)
    expect(res, toFetch: platformBuildings)
  }

  @Test("Throws an error when file does not exist")
  func throwsErrorOnFileNotExisting() {
    // Given
    let mockFileLoader = MockFileLoader(throws: FileLoaderError.fileNotFound)
    let sut = LiveJSONLoader<[PlatformBuilding]>(using: mockFileLoader)

    // When
    let res = sut.load(from: "fakeFilePath/fake")

    // Then
    expect(res, toThrow: .fileNotFound)
  }

  @Test("Throws an error when JSON in file is malformed")
  func throwsErrorOnMalformedJSON() {
    // Given
    let mockFileLoader = MockFileLoader(loads: fakeBuildingsMalformedJSON)
    let sut = LiveJSONLoader<[PlatformBuilding]>(using: mockFileLoader)

    // When
    let res = sut.load(from: "fakeFilePath/fake")

    // Then
    expect(res, toThrow: .malformedJSON)
  }

  // MARK: Private

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

  private func expect(_ res: LiveJSONLoader<[PlatformBuilding]>.Result, toThrow _: LiveJSONLoaderError) {
    switch res {
    case .failure(let error):
      #expect(error == error)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: LiveJSONLoader<[PlatformBuilding]>.Result, toFetch _: [PlatformBuilding]) {
    switch res {
    case .success(let buildings):
      #expect(buildings == buildings)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

  private func createPlatformBuildings(_ count: Int) -> [PlatformBuilding] {
    var platformBuildings: [PlatformBuilding] = []
    for _ in 0..<count {
      platformBuildings.append(PlatformBuilding(name: "name", id: "123", lat: 1.0, long: 1.0, aliases: ["A", "B"]))
    }
    return platformBuildings
  }

}
