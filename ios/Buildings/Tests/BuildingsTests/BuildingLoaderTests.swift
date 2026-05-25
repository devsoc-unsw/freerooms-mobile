//
//  BuildingLoaderTests.swift
//  Buildings
//
//  Created by Chris Wong on 1/5/2025.
//

import BuildingModels
import Foundation
import Persistence
import PersistenceTestUtils
import SwiftData
import Testing
@testable import BuildingServices
@testable import RoomServices

@Suite(.serialized)
class BuildingLoaderTests {

  // MARK: Lifecycle

  init() {
    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.hasSavedBuildingsData)
  }

  deinit {
    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.hasSavedBuildingsData)
  }

  // MARK: Internal

  @Test(
    "First load of buildings gets zero buildings successfully and sets UserDefaults flag indicating data has been loaded will be turned on")
  func onFirstLoadSuccessfullyLoadsZeroBuilding() async throws {
    // Given
    let buildings = createBuildings(0)
    let stubJSONBuildingLoader = StubJSONBuildingLoader()
    stubJSONBuildingLoader.fetchReturnValue = .success(buildings)
    let stubSwiftDataBuildingLoader = StubSwiftDataBuildingLoader()
    stubSwiftDataBuildingLoader.fetchReturnValue = .success(buildings)
    stubSwiftDataBuildingLoader.seedReturnValue = .success(())
    let stubRoomStatusLoader = StubRoomStatusLoader()
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .failure(.connectivity)
    let stubBuildingRatingLoader = StubBuildingRatingLoader()
    stubBuildingRatingLoader.fetchReturnValue = .failure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: stubSwiftDataBuildingLoader,
      JSONBuildingLoader: stubJSONBuildingLoader,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)

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
    let stubJSONBuildingLoader = StubJSONBuildingLoader()
    stubJSONBuildingLoader.fetchReturnValue = .success(buildings)
    let stubSwiftDataBuildingLoader = StubSwiftDataBuildingLoader()
    stubSwiftDataBuildingLoader.fetchReturnValue = .success(buildings)
    stubSwiftDataBuildingLoader.seedReturnValue = .success(())
    let stubRoomStatusLoader = StubRoomStatusLoader()
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .failure(.connectivity)
    let stubBuildingRatingLoader = StubBuildingRatingLoader()
    stubBuildingRatingLoader.fetchReturnValue = .failure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: stubSwiftDataBuildingLoader,
      JSONBuildingLoader: stubJSONBuildingLoader,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)

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
    let stubJSONBuildingLoader = StubJSONBuildingLoader()
    stubJSONBuildingLoader.fetchReturnValue = .success(buildings)
    let stubSwiftDataBuildingLoader = StubSwiftDataBuildingLoader()
    stubSwiftDataBuildingLoader.fetchReturnValue = .success(buildings)
    stubSwiftDataBuildingLoader.seedReturnValue = .success(())
    let stubRoomStatusLoader = StubRoomStatusLoader()
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .failure(.connectivity)
    let stubBuildingRatingLoader = StubBuildingRatingLoader()
    stubBuildingRatingLoader.fetchReturnValue = .failure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: stubSwiftDataBuildingLoader,
      JSONBuildingLoader: stubJSONBuildingLoader,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)

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
    let stubJSONBuildingLoader = StubJSONBuildingLoader()
    stubJSONBuildingLoader.fetchReturnValue = .failure(.malformedJSON)
    let stubSwiftDataBuildingLoader = StubSwiftDataBuildingLoader()
    stubSwiftDataBuildingLoader.fetchReturnValue = .success(buildings)
    stubSwiftDataBuildingLoader.seedReturnValue = .success(())
    let stubRoomStatusLoader = StubRoomStatusLoader()
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .failure(.connectivity)
    let stubBuildingRatingLoader = StubBuildingRatingLoader()
    stubBuildingRatingLoader.fetchReturnValue = .failure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: stubSwiftDataBuildingLoader,
      JSONBuildingLoader: stubJSONBuildingLoader,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)

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
    let stubJSONBuildingLoader = StubJSONBuildingLoader()
    stubJSONBuildingLoader.fetchReturnValue = .success(buildings)
    let stubSwiftDataBuildingLoader = StubSwiftDataBuildingLoader()
    stubSwiftDataBuildingLoader.seedReturnValue = .failure(.persistenceError)
    stubSwiftDataBuildingLoader.fetchReturnValue = .success([])
    let stubRoomStatusLoader = StubRoomStatusLoader()
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .failure(.connectivity)
    let stubBuildingRatingLoader = StubBuildingRatingLoader()
    stubBuildingRatingLoader.fetchReturnValue = .failure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: stubSwiftDataBuildingLoader,
      JSONBuildingLoader: stubJSONBuildingLoader,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)

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
    let stubJSONBuildingLoader = StubJSONBuildingLoader()
    stubJSONBuildingLoader.fetchReturnValue = .success(buildings)
    let stubSwiftDataBuildingLoader = StubSwiftDataBuildingLoader()
    stubSwiftDataBuildingLoader.fetchReturnValue = .success(buildings)
    stubSwiftDataBuildingLoader.seedReturnValue = .success(())
    let stubRoomStatusLoader = StubRoomStatusLoader()
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .failure(.connectivity)
    let stubBuildingRatingLoader = StubBuildingRatingLoader()
    stubBuildingRatingLoader.fetchReturnValue = .failure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: stubSwiftDataBuildingLoader,
      JSONBuildingLoader: stubJSONBuildingLoader,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)
    _ = await sut.fetch()

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
    let stubJSONBuildingLoader = StubJSONBuildingLoader()
    stubJSONBuildingLoader.fetchReturnValue = .success(buildings)
    let stubSwiftDataBuildingLoader = StubSwiftDataBuildingLoader()
    stubSwiftDataBuildingLoader.fetchReturnValue = .failure(.persistenceError)
    stubSwiftDataBuildingLoader.seedReturnValue = .success(())
    let stubRoomStatusLoader = StubRoomStatusLoader()
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .failure(.connectivity)
    let stubBuildingRatingLoader = StubBuildingRatingLoader()
    stubBuildingRatingLoader.fetchReturnValue = .failure(.connectivity)
    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: stubSwiftDataBuildingLoader,
      JSONBuildingLoader: stubJSONBuildingLoader,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)
    _ = await sut.fetch()

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
    let stubRoomStatusLoader = StubRoomStatusLoader()
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .failure(.connectivity)
    let stubBuildingRatingLoader = StubBuildingRatingLoader()
    stubBuildingRatingLoader.fetchReturnValue = .failure(.connectivity)

    let schema = Schema([SwiftDataBuilding.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    let modelContext = ModelContext(modelContainer)
    let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: modelContext)
    let liveSwiftDataBuildingLoader = LiveSwiftDataBuildingLoader(swiftDataStore: swiftDataStore)

    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: liveSwiftDataBuildingLoader,
      JSONBuildingLoader: liveJSONBuildingLoader,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)

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
    let stubRoomStatusLoader = StubRoomStatusLoader()
    stubRoomStatusLoader.fetchRoomStatusReturnValue = .failure(.connectivity)
    let stubBuildingRatingLoader = StubBuildingRatingLoader()
    stubBuildingRatingLoader.fetchReturnValue = .failure(.connectivity)

    let schema = Schema([SwiftDataBuilding.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
    let modelContext = ModelContext(modelContainer)
    let swiftDataStore = try SwiftDataStore<SwiftDataBuilding>(modelContext: modelContext)
    let liveSwiftDataBuildingLoader = LiveSwiftDataBuildingLoader(swiftDataStore: swiftDataStore)

    let sut = LiveBuildingLoader(
      swiftDataBuildingLoader: liveSwiftDataBuildingLoader,
      JSONBuildingLoader: liveJSONBuildingLoader,
      roomStatusLoader: stubRoomStatusLoader,
      buildingRatingLoader: stubBuildingRatingLoader)
    _ = await sut.fetch()

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
      buildings.sort { $0.name < $1.name }
      #expect(buildings == expected)

    case .failure(let error):
      Issue.record("Expected success but got \(error)")
    }
  }

  private func createBuildings(_ count: Int) -> [Building] {
    var buildings = [Building]()
    for _ in 0..<count {
      buildings.append(Building(name: "name", id: "123", latitude: 1.0, longitude: 1.0, aliases: ["A", "B"]))
    }
    return buildings
  }
}
