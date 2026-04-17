//
//  FavoriteRoomServiceTests.swift
//  Rooms
//
//  Created by Matthew Yuen on 17/4/2026.
//

import Foundation
import RoomModels
import RoomServices
import SwiftData
import Testing

@Suite
struct FavoriteRoomServiceTests {

  @Suite
  struct SwiftDataTests {

    // MARK: Lifecycle

    init() throws {
      let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
      let modelContainer = try ModelContainer(for: SwiftDataFavoriteRoom.self, configurations: configuration)
      self.modelContainer = modelContainer
      favoritesService = try SwiftDataFavoriteRoomService(context: modelContainer.mainContext)
    }

    // MARK: Internal

    let modelContainer: ModelContainer
    let favoritesService: SwiftDataFavoriteRoomService

    @Test
    func `Starts out empty`() {
      #expect(favoritesService.getAllFavoriteRoomIds().isEmpty)
    }

    @Test(arguments: [1, 10, 100])
    func `Can add favorite rooms`(_ roomCount: Int) {
      let roomIDs = Set((0..<roomCount).map { _ in UUID().uuidString })
      for roomID in roomIDs {
        favoritesService.addFavorite(roomID: roomID)
      }
      #expect(Set(favoritesService.getAllFavoriteRoomIds()) == roomIDs)
    }

    @Test(arguments: [1, 10, 100])
    func `Can check if room is favorited`(_ roomCount: Int) {
      let roomIDs = Set((0..<roomCount).map { _ in UUID().uuidString })
      for roomID in roomIDs {
        favoritesService.addFavorite(roomID: roomID)
      }
      let testRoomID = roomIDs.randomElement()
      #expect(favoritesService.isFavorite(roomID: testRoomID!))
    }

    @Test
    func `Non favorite room is not found as favorite`() {
      let testRoomID = UUID().uuidString
      #expect(!favoritesService.isFavorite(roomID: testRoomID))
    }

  }

}
