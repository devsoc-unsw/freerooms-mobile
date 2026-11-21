//
//  RoomDistanceTests.swift
//  Rooms
//
//  Created by Eric Wong on 21/11/2026.
//

import RoomModels
import Testing
@testable import Location
@testable import RoomInteractors
@testable import RoomServices
@testable import RoomTestUtils
@testable import TestingSupport

struct RoomDistanceTests {

  // MARK: Internal

  @Test("Measures from the user to the room's own coordinates")
  func measuresToRoomCoordinates() {
    // Given: 0.001° of latitude is about 111 m.
    let room = makeRoomNorthOfUser(id: "K-A1-101", buildingId: "K-A1", latitudeOffset: 0.001)
    let sut = makeSUT()

    // When
    let distances = sut.getRoomDistances([room], from: userLocation, buildingDistances: ["K-A1": 999])

    // Then
    #expect(abs((distances["K-A1-101"] ?? 0) - 111) < 2)
  }

  @Test("A room without coordinates uses its building's distance")
  func fallsBackToBuildingDistance() {
    // Given: the data stores rooms without coordinates at 0, 0.
    let room = RoomsTests.makeRoom("250", in: "K-C27") // ID "K-C27-250"
    let sut = makeSUT()

    // When
    let distances = sut.getRoomDistances([room], from: userLocation, buildingDistances: ["K-C27": 240])

    // Then
    #expect(distances["K-C27-250"] == 240)
  }

  @Test("A room without coordinates or a building distance is left out")
  func leavesOutRoomWithNoDistance() {
    // Given
    let room = RoomsTests.makeRoom("250", in: "K-C27") // ID "K-C27-250"
    let sut = makeSUT()

    // When
    let distances = sut.getRoomDistances([room], from: userLocation, buildingDistances: [:])

    // Then
    #expect(distances["K-C27-250"] == nil)
  }

  // MARK: Private

  /// Roughly the middle of UNSW Kensington.
  private let userLocation = Location(latitude: -33.9173, longitude: 151.2312)

  /// A room offset north of `userLocation` by the given number of degrees.
  private func makeRoomNorthOfUser(id: String, buildingId: String, latitudeOffset: Double) -> Room {
    let template = RoomsTests.makeRoom(id, in: buildingId)
    return Room(
      abbreviation: template.abbreviation,
      accessibility: template.accessibility,
      audioVisual: template.audioVisual,
      buildingId: buildingId,
      capacity: template.capacity,
      floor: template.floor,
      id: id,
      infoTechnology: template.infoTechnology,
      latitude: userLocation.latitude + latitudeOffset,
      longitude: userLocation.longitude,
      microphone: template.microphone,
      name: template.name,
      school: template.school,
      seating: template.seating,
      usage: template.usage,
      service: template.service,
      writingMedia: template.writingMedia,
      status: template.status,
      endTime: template.endTime,
      overallRating: template.overallRating)
  }

  private func makeSUT() -> RoomInteractor {
    let roomService = LiveRoomService(
      roomLoader: StubRoomLoader(),
      roomBookingLoader: LiveRoomBookingLoader(remoteRoomBookingLoader: StubRemoteRoomBookingLoader()),
      roomRatingLoader: StubRoomRatingLoader(),
      roomFilterService: StubFilterRoomService())
    return RoomInteractor(
      roomService: roomService,
      favouriteService: PreviewFavoriteRoomService())
  }
}
