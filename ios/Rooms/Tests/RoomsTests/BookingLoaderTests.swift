//
//  BookingLoaderTests.swift
//  Rooms
//
//  Created by Chris Wong on 4/9/2025.
//

import RoomModels
import RoomServices
import Testing
@testable import RoomTestUtils
@testable import TestingSupport

struct BookingLoaderTests {
  @Test("Booking loader successfully loads loads 1 room booking")
  func BookingLoaderSuccessfullyLoadsOneBooking() async {
    // Given
    let remoteRoomBookings = createRemoteRoomBookings(1)
    let roomBookings = createRoomBookings(1)
    let mockRemoteRoomBookingLoader = MockRemoteRoomBookingLoader(loads: remoteRoomBookings)
    let sut = LiveRoomBookingLoader(remoteRoomBookingLoader: mockRemoteRoomBookingLoader)

    // When
    let res = await sut.fetch(bookingsOf: "1")

    // Then
    expect(res, toFetch: roomBookings)
  }

  @Test("Booking loader successfully loads loads 0 room booking")
  func BookingLoaderSuccessfullyLoadsZeroBooking() async {
    // Given
    let remoteRoomBookings = createRemoteRoomBookings(0)
    let roomBookings = createRoomBookings(0)
    let mockRemoteRoomBookingLoader = MockRemoteRoomBookingLoader(loads: remoteRoomBookings)
    let sut = LiveRoomBookingLoader(remoteRoomBookingLoader: mockRemoteRoomBookingLoader)

    // When
    let res = await sut.fetch(bookingsOf: "1")

    // Then
    expect(res, toFetch: roomBookings)
  }

  @Test("Booking loader successfully loads loads 10 room booking")
  func BookingLoaderSuccessfullyLoadsTenBooking() async {
    // Given
    let remoteRoomBookings = createRemoteRoomBookings(10)
    let roomBookings = createRoomBookings(10)
    let mockRemoteRoomBookingLoader = MockRemoteRoomBookingLoader(loads: remoteRoomBookings)
    let sut = LiveRoomBookingLoader(remoteRoomBookingLoader: mockRemoteRoomBookingLoader)

    // When
    let res = await sut.fetch(bookingsOf: "1")

    // Then
    expect(res, toFetch: roomBookings)
  }

  @Test("Booking loader throws error on network failures")
  func BookingLoaderThrowsErrorOnNetworkFailure() async throws {
    // Given
    let mockRemoteRoomBookingLoader = MockRemoteRoomBookingLoader(throws: .connectivity)
    let sut = LiveRoomBookingLoader(remoteRoomBookingLoader: mockRemoteRoomBookingLoader)

    // When
    let res = await sut.fetch(bookingsOf: "1")

    // Then
    expect(res, toThrow: .connectivity)
  }

  @Test("Booking loader throws error on empty building id")
  func BookingLoaderThrowsErrorOnEmptyBuildingId() async throws {
    // Given
    let remoteRoomBookings = createRemoteRoomBookings(10)
    let mockRemoteRoomBookingLoader = MockRemoteRoomBookingLoader(loads: remoteRoomBookings)
    let sut = LiveRoomBookingLoader(remoteRoomBookingLoader: mockRemoteRoomBookingLoader)

    // When
    let res = await sut.fetch(bookingsOf: "")

    // Then
    expect(res, toThrow: .invalidBuildingID)
  }

  @Test("Booking loader throws error on invalid building id")
  func BookingLoaderThrowsErrorOnInvalidBuildingId() async throws {
    // Given
    let mockRemoteRoomBookingLoader = MockRemoteRoomBookingLoader(throws: .invalidBuildingID)
    let sut = LiveRoomBookingLoader(remoteRoomBookingLoader: mockRemoteRoomBookingLoader)

    // When
    let res = await sut.fetch(bookingsOf: "invalid")

    // Then
    expect(res, toThrow: .invalidBuildingID)
  }
}
