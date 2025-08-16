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
@testable import TestingSupport

struct JSONBuildingLoaderTests {

  // MARK: Internal

  @Test("Check buildings bundle string exists")
  func checkBuildingsBundleStringExists() async throws {
    let decodableBuildings = createDecodableBuildings(0)
    let mockJSONLoader = MockJSONLoader<DecodableBuildingData>(loads: decodableBuildings)
    let JSONBuildingLoader = LiveJSONBuildingLoader(using: mockJSONLoader)
    if JSONBuildingLoader.buildingsSeedJSONPath == nil {
      Issue.record("Buildings Seed JSON not found in bundle")
    }
  }

  @Test("Live JSON building loader successfully decodes JSON into type [Building]")
  func liveJSONBuildingLoaderSuccessfullyDecodesJSON() {
    // Given
    let decodableBuildings = createDecodableBuildings(10)
    let mockJSONLoader = MockJSONLoader<DecodableBuildingData>(loads: decodableBuildings)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = sut.fetch()

    // Then
    let buildings = createBuildings(10)
    expect(res, toFetch: buildings)
  }

  @Test("Live JSON building loader successfully decodes empty JSON into type [Building]")
  func liveJSONBuildingLoaderSuccessfullyDecodesEmptyJSON() {
    // Given
    let decodableBuildings = createDecodableBuildings(0)
    let mockJSONLoader = MockJSONLoader<DecodableBuildingData>(loads: decodableBuildings)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = sut.fetch()

    // Then
    let buildings = [Building]()
    expect(res, toFetch: buildings)
  }

  @Test("Live JSON building loader returns error when JSON loader cannot find file")
  func liveJSONBuildingLoaderThrowsErrorOnNoFileFound() {
    // Given
    let mockJSONLoader = MockJSONLoader<DecodableBuildingData>(throws: JSONLoaderError.fileNotFound)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = sut.fetch()

    // Then
    expect(res, toThrow: .fileNotFound)
  }

  @Test("Live JSON building loader returns error when JSON loader cannot read malformed JSON")
  func liveJSONBuildingLoaderThrowsErrorOnMalformedJson() {
    // Given
    let mockJSONLoader = MockJSONLoader<DecodableBuildingData>(throws: JSONLoaderError.malformedJSON)
    let sut = LiveJSONBuildingLoader(using: mockJSONLoader)

    // When
    let res = sut.fetch()

    // Then
    expect(res, toThrow: .malformedJSON)
  }

  @Test("Live JSON building loader integration with Live JSON loader successfully loads buildings from JSON file")
  func liveJSONBuildingLoaderIntegratesWithLiveJSONLoaderSuccessfully() async throws {
    // Given
    let realBuildingsData = createRealBuildings()
    let liveFileLoader = LiveFileLoader()
    let liveJSONLoader = LiveJSONLoader<DecodableBuildingData>(using: liveFileLoader)
    let liveJSONBuildingLoader = LiveJSONBuildingLoader(using: liveJSONLoader)

    // When
    let res = liveJSONBuildingLoader.fetch()

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

  private func createDecodableBuildings(_ count: Int) -> DecodableBuildingData {
    var decodableBuildings: [DecodableBuilding] = []
    for _ in 0..<count {
      decodableBuildings.append(DecodableBuilding(name: "name", id: "123", lat: 1.0, long: 1.0, aliases: ["A", "B"]))
    }
    let decodableBuildingsKey = DecodableBuildings(buildings: decodableBuildings)
    return DecodableBuildingData(data: decodableBuildingsKey)
  }

  private func createBuildings(_ count: Int) -> [Building] {
    var buildings: [Building] = []
    for _ in 0..<count {
      buildings.append(Building(name: "name", id: "123", latitude: 1.0, longitude: 1.0, aliases: ["A", "B"]))
    }
    return buildings
  }

  private func createRealBuildings() -> [Building] {
    let buildingsData = [
      ("AGSM", "K-G27", -33.91852, 151.235664, []),
      ("Ainsworth Building", "K-J17", -33.918527, 151.23126, []),
      ("Biological Sciences (West)", "K-D26", -33.917381, 151.235403, []),
      ("Biological Sciences", "K-E26", -33.917682, 151.235736, []),
      ("Blockhouse", "K-G6", -33.916937, 151.226826, []),
      ("Civil Engineering Building", "K-H20", -33.918234, 151.232835, []),
      ("Colombo Building", "K-B16", -33.915902, 151.231367, []),
      ("Computer Science & Eng (K17)", "K-K17", -33.918929, 151.231055, []),
      ("Dalton Building", "K-F12", -33.917502, 151.229353, []),
      ("Patricia OShane", "K-E19", -33.917177, 151.232511, ["Central Lecture Block"]),
      ("Electrical Engineering Bldg", "K-G17", -33.91779, 151.2315, []),
      ("Esme Timbery Creative Practice", "K-D8", 0, 0, []),
      ("June Griffith", "K-F10", -33.917108, 151.228826, ["Chemical Sciences"]),
      ("Gordon Jacqueline Samuels", "K-F25", -33.917892, 151.235139, []),
      ("Anita B Lawrence Centre", "K-H13", -33.917876, 151.230057, ["Red Centre"]),
      ("Integrated Acute Services Bldg", "K-F31", 0, 0, []),
      ("John Goodsell Building", "K-F20", -33.917492, 151.232712, []),
      ("John Niland Scientia", "K-G19", -33.918, 151.23239, []),
      ("Keith Burrows Theatre", "K-J14", -33.918207, 151.230109, []),
      ("Law Building", "K-F8", -33.917004, 151.227791, ["Law Library"]),
      ("Main Library", "K-F21", -33.917528, 151.233439, []),
      ("Material Science & Engineering", "K-E10", -33.916458, 151.228459, ["Hilmer Building"]),
      ("Mathews Building", "K-F23", -33.917741, 151.234563, []),
      ("Mathews Theatres", "K-D23", -33.917178, 151.234177, []),
      ("Morven Brown Building", "K-C20", -33.916792, 151.232828, []),
      ("Newton Building", "K-J12", -33.91812, 151.229211, []),
      ("Old Main Building", "K-K15", -33.918507, 151.229457, []),
      ("Physics Theatre", "K-K14", -33.918514, 151.230082, []),
      ("Quadrangle Building", "K-E15", -33.917264, 151.230955, []),
      ("Rex Vowels Theatre", "K-F17", -33.917536, 151.231493, []),
      ("Rupert Myers Building", "K-M15", -33.919533, 151.230552, []),
      ("Science & Engineering Building", "K-E8", -33.91654, 151.227689, []),
      ("Science Theatre", "K-F13", -33.917204, 151.229831, []),
      ("Sir John Clancy Auditorium", "K-C24", -33.91696, 151.234542, []),
      ("Squarehouse", "K-E4", -33.916185, 151.226284, []),
      ("Tyree Energy Technology", "K-H6", -33.917721, 151.226897, []),
      ("Business School", "K-E12", -33.9168, 151.229611, []),
      ("Goldstein", "K-D16", -33.916585, 151.231394, []),
      ("Vallentine Annexe", "K-H22", -33.918306, 151.233301, []),
      ("Wallace Wurth Building", "K-C27", -33.916744, 151.235681, []),
      ("Webster Building", "K-G14", -33.91764, 151.230611, []),
      ("Webster Theatres", "K-G15", -33.917435, 151.230668, []),
      ("Willis Annexe", "K-J18", -33.918778, 151.231675, []),
    ]

    return buildingsData.map {
      Building(name: $0.0, id: $0.1, latitude: $0.2, longitude: $0.3, aliases: $0.4)
    }
  }
}
