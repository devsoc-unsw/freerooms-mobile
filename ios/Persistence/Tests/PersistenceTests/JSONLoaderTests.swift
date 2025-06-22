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
    let mockFileLoader = MockFileLoader(loads: "Data")
    let sut = LiveJSONLoader<PlatformBuilding>(decodes: "buildings", with: mockFileLoader)

    // When
    let res = sut.load(from: "fakeFilePath/fake")

    // Then
    let platformBuildings = [PlatformBuilding]()
    expect(res, toFetch: platformBuildings)
  }

  @Test("Throws an error when file does not exist")
  func throwsErrorOnFileNotExisting() {
    // Given
    let mockFileLoader = MockFileLoader(throws: FileLoaderError.fileNotFound)
    let sut = LiveJSONLoader<PlatformBuilding>(decodes: "buildings", with: mockFileLoader)

    // When
    let res = sut.load(from: "fakeFilePath/fake")

    // Then
    expect(res, toThrow: .fileNotFound)
  }

  @Test("Throws an error when JSON in file is malformed")
  func throwsErrorOnMalformedJSON() {
    // Given
    let mockFileLoader = MockFileLoader(loads: "Malformed data")
    let sut = LiveJSONLoader<PlatformBuilding>(decodes: "buildings", with: mockFileLoader)

    // When
    let res = sut.load(from: "fakeFilePath/fake")

    // Then
    expect(res, toThrow: .malformedJSON)
  }

  // MARK: Private

  private func expect(_ res: LiveJSONLoader<PlatformBuilding>.Result, toThrow _: LiveJSONLoaderError) {
    switch res {
    case .failure(let error):
      #expect(error == error)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: LiveJSONLoader<PlatformBuilding>.Result, toFetch _: [PlatformBuilding]) {
    switch res {
    case .success(let buildings):
      #expect(buildings == buildings)
    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

}
