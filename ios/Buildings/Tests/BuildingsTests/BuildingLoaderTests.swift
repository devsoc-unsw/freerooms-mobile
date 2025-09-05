//
//  BuildingLoaderTests.swift
//  Buildings
//
//  Created by Chris Wong on 1/5/2025.
//

import BuildingModels
import BuildingServices
import Foundation
import Persistence
import PersistenceTestUtils
import RoomServices
import SwiftData
import Testing
@testable import BuildingTestUtils
@testable import RoomTestUtils

@Suite(.serialized)
class BuildingLoaderTests {

  // MARK: Lifecycle

  deinit {
    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.hasSavedBuildingsData)
  }

  // MARK: Internal

  @Test(
    "First load of buildings gets zero buildings successfully and sets UserDefaults flag indicating data has been loaded will be turned on")
  func onFirstLoadSuccessfullyLoadsZeroBuilding() async throws {
    // Given
    let buildings = createBuildings(0)
    let mockJSONBuildingLoader = JSONBuildingLoaderMock(loads: buildings)
    let swiftDataBuildingMock = SwiftDataBuildingLoaderMock(loads: buildings)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubFailure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: swiftDataBuildingMock,
      JSONBuildingLoader: mockJSONBuildingLoader,
      roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    #expect(UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData) == true)
    expect(res, toFetch: buildings)
  }

  @Test(
    "First load of buildings gets one building successfully and sets UserDefaults flag indicating data has been loaded will be turned on")
  func onFirstLoadSuccessfullyLoadsOneBuilding() async throws {
    // Given
    let buildings = createBuildings(1)
    let mockJSONBuildingLoader = JSONBuildingLoaderMock(loads: buildings)
    let swiftDataBuildingMock = SwiftDataBuildingLoaderMock(loads: buildings)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubFailure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: swiftDataBuildingMock,
      JSONBuildingLoader: mockJSONBuildingLoader,
      roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    #expect(UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData) == true)
    expect(res, toFetch: buildings)
  }

  @Test(
    "First load of buildings gets ten buildings successfully and sets UserDefaults flag indicating data has been loaded will be turned on")
  func onFirstLoadSuccessfullyLoadsTenBuilding() async throws {
    // Given
    let buildings = createBuildings(10)
    let mockJSONBuildingLoader = JSONBuildingLoaderMock(loads: buildings)
    let swiftDataBuildingMock = SwiftDataBuildingLoaderMock(loads: buildings)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubFailure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: swiftDataBuildingMock,
      JSONBuildingLoader: mockJSONBuildingLoader,
      roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    #expect(UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData) == true)
    expect(res, toFetch: buildings)
  }

  @Test("First load of buildings, JSON Building Loader throws an error so buildings loader will throw an error")
  func onFirstLoadJSONBuildingLoaderThrowsError() async throws {
    // Given
    let buildings = createBuildings(10)
    let mockJSONBuildingLoader = JSONBuildingLoaderMock(throws: .malformedJSON)
    let swiftDataBuildingMock = SwiftDataBuildingLoaderMock(loads: buildings)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubFailure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: swiftDataBuildingMock,
      JSONBuildingLoader: mockJSONBuildingLoader,
      roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    #expect(UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData) == false)
    expect(res, toThrow: .malformedJSON)
  }

  @Test(
    "First load of buildings, Swift Data Building Loader throws an error so buildings will still be returned but UserDefaults flag indicating data has loaded will not be turned on")
  func onFirstLoadSwiftDataBuildingLoaderThrowsError() async throws {
    // Given
    let buildings = createBuildings(10)
    let mockJSONBuildingLoader = JSONBuildingLoaderMock(loads: buildings)
    let swiftDataBuildingMock = SwiftDataBuildingLoaderMock(onSeedThrows: .persistenceError)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubFailure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: swiftDataBuildingMock,
      JSONBuildingLoader: mockJSONBuildingLoader,
      roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    #expect(UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData) == false)
    expect(res, toThrow: .persistenceError)
  }

  @Test("Subsequent loads of buildings gets the buildings successfully")
  func onSubsequentLoadsSuccessfullyLoadsBuildings() async throws {
    // Given
    let buildings = createBuildings(10)
    let mockJSONBuildingLoader = JSONBuildingLoaderMock(loads: buildings)
    let swiftDataBuildingMock = SwiftDataBuildingLoaderMock(loads: buildings)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubFailure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: swiftDataBuildingMock,
      JSONBuildingLoader: mockJSONBuildingLoader,
      roomStatusLoader: mockRoomStatusLoader)
    let _ = await sut.fetch()

    // When
    let res = await sut.fetch()

    // Then
    #expect(UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData) == true)
    expect(res, toFetch: buildings)
  }

  @Test("Subsequent loads of buildings, Swift Data Building Loader throws an error so buildings will throw an error")
  func onSubsequentLoadsSwiftDataBuildingLoaderThrowsError() async throws {
    // Given
    let buildings = createBuildings(10)
    let mockJSONBuildingLoader = JSONBuildingLoaderMock(loads: buildings)
    let swiftDataBuildingMock = SwiftDataBuildingLoaderMock(onFetchThrows: .persistenceError)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubFailure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: swiftDataBuildingMock,
      JSONBuildingLoader: mockJSONBuildingLoader,
      roomStatusLoader: mockRoomStatusLoader)
    let _ = await sut.fetch()

    // When
    let res = await sut.fetch()

    // Then
    #expect(UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedBuildingsData) == true)
    expect(res, toThrow: .persistenceError)
  }

  @Test(
    "Live Building Loader integrates with Live JSON Building Loader and Live Swift Data Building Loader successfully returning buildings on first load")
  func liveBuildingLoaderIntegratesSuccessfullyWithLiveUnitsOnFirstLoad() async throws {
    // Given
    let realBuildings = createRealBuildings()
    let liveFileLoader = LiveFileLoader()
    let liveJSONLoader = LiveJSONLoader<[DecodableBuilding]>(using: liveFileLoader)
    let liveJSONBuildingLoader = LiveJSONBuildingLoader(using: liveJSONLoader)
    let swiftDataBuildingMock = SwiftDataBuildingLoaderMock(onSeedThrows: .persistenceError)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubFailure(.connectivity)

    let schema = Schema([SwiftDataBuilding.self])
    let modelConfiguration = ModelConfiguration(schema: schema)
    let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    let modelContext = ModelContext(modelContainer)
    let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: modelContext)
    let liveSwiftDataBuildingLoader = LiveSwiftDataBuildingLoader(swiftDataStore: swiftDataStore)

    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: liveSwiftDataBuildingLoader,
      JSONBuildingLoader: liveJSONBuildingLoader, roomStatusLoader: mockRoomStatusLoader)

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toFetch: realBuildings)
  }

  @Test(
    "Live Building Loader integrates with Live JSON Building Loader and Live Swift Data Building Loader successfully returning buildings on subsequent loads")
  func liveBuildingLoaderIntegratesSuccessfullyWithLiveUnitsOnSubsequentLoads() async throws {
    // Given
    let realBuildings = createRealBuildings()
    let liveFileLoader = LiveFileLoader()
    let liveJSONLoader = LiveJSONLoader<[DecodableBuilding]>(using: liveFileLoader)
    let liveJSONBuildingLoader = LiveJSONBuildingLoader(using: liveJSONLoader)
    let mockRoomStatusLoader = MockRoomStatusLoader()
    mockRoomStatusLoader.stubFailure(.connectivity)

    let schema = Schema([SwiftDataBuilding.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    let modelContext = ModelContext(modelContainer)
    let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: modelContext)
    let liveSwiftDataBuildingLoader = LiveSwiftDataBuildingLoader(swiftDataStore: swiftDataStore)

    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: liveSwiftDataBuildingLoader,
      JSONBuildingLoader: liveJSONBuildingLoader, roomStatusLoader: mockRoomStatusLoader)
    let _ = await sut.fetch()

    // When
    let res = await sut.fetch()

    // Then
    expect(res, toFetch: realBuildings)
  }

  // MARK: Private

  private func expect(_ res: LiveBuildingLoader.Result, toThrow expected: BuildingLoaderError) {
    switch res {
    case .failure(let error):
      #expect(error == expected)
    case .success(let response):
      Issue.record("Expected an error but got \(response)")
    }
  }

  private func expect(_ res: LiveBuildingLoader.Result, toFetch expected: [Building]) {
    switch res {
    case .success(var buildings):
      buildings.sort { $0.id < $1.id }
      #expect(buildings == expected)

    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
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
    }.sorted { $0.id < $1.id }
  }

}
