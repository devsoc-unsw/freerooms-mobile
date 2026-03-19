//
//  RoomRatingLoaderTests.swift
//  RoomsTests
//
//  Created by Dicko Evaldo on 19/3/2026.
//

import Foundation
import RoomModels
import Testing
@testable import NetworkingTestUtils
@testable import RoomServices

struct RoomRatingLoaderTests {

  @Test("Rating loader returns rating for valid room ID")
  func ratingLoaderReturnsRatingForValidRoomID() async {
    // Given
    let expectedRating = makeRoomRating()
    let client = MockHTTPClient()
    client.stubSuccess(expectedRating, for: "")
    let sut = LiveRoomRatingLoader(client: client, baseURL: makeBaseURL())

    // When
    let result = await sut.fetchRoomRating(roomID: "K-J17-G03")

    // Then
    expect(result, toFetch: expectedRating)
  }

  @Test("Rating loader returns invalidRoomID error for empty room ID")
  func ratingLoaderReturnsInvalidRoomIDForEmptyID() async {
    // Given
    let client = MockHTTPClient()
    let sut = LiveRoomRatingLoader(client: client, baseURL: makeBaseURL())

    // When
    let result = await sut.fetchRoomRating(roomID: "")

    // Then
    expect(result, toThrow: .invalidRoomID)
  }

  @Test("Rating loader returns connectivity error on network failure")
  func ratingLoaderReturnsConnectivityErrorOnNetworkFailure() async {
    // Given
    let client = MockHTTPClient()
    client.stubFailure()
    let sut = LiveRoomRatingLoader(client: client, baseURL: makeBaseURL())

    // When
    let result = await sut.fetchRoomRating(roomID: "K-J17-G03")

    // Then
    expect(result, toThrow: .connectivity)
  }
}

// MARK: - Helpers

private func makeBaseURL() -> URL {
  URL(string: "https://freerooms.devsoc.app")!
}

private func makeRoomRating() -> RoomRating {
  RoomRating(
    roomId: "K-J17-G03",
    overallRating: 4.0,
    averageRating: AverageRating(cleanliness: 5.0, location: 5.0, quietness: 4.0))
}

private func expect(
  _ result: Result<RoomRating, RoomRatingLoaderError>,
  toFetch expected: RoomRating,
  sourceLocation: SourceLocation = #_sourceLocation)
{
  switch result {
  case .success(let rating):
    #expect(rating == expected, sourceLocation: sourceLocation)
  case .failure(let error):
    Issue.record("Expected success but got \(error)", sourceLocation: sourceLocation)
  }
}

private func expect(
  _ result: Result<RoomRating, RoomRatingLoaderError>,
  toThrow expected: RoomRatingLoaderError,
  sourceLocation: SourceLocation = #_sourceLocation)
{
  switch result {
  case .success(let rating):
    Issue.record("Expected failure but got \(rating)", sourceLocation: sourceLocation)
  case .failure(let error):
    #expect(error == expected, sourceLocation: sourceLocation)
  }
}
