//
//  BookingPresentationTests.swift
//  BookingsTests
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingModels
import Foundation
import Testing
@testable import BookingViews

@Suite
struct BookingPresentationTests {

  // MARK: Internal

  @Test("Bookings are grouped by local day and sorted within each section")
  func groupsAndSortsBookings() throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let early = makeBooking(title: "Early", start: try date("2026-12-24T09:00:00Z"))
    let late = makeBooking(title: "Late", start: try date("2026-12-24T12:00:00Z"))
    let nextDay = makeBooking(title: "Next", start: try date("2026-12-25T09:00:00Z"))

    let groups = BookingListGrouping.groups(from: [nextDay, late, early], calendar: calendar)

    #expect(groups.count == 2)
    #expect(groups[0].bookings.map(\.title) == ["Early", "Late"])
    #expect(groups[1].bookings.map(\.title) == ["Next"])
  }

  @Test("Event search matches title substrings without case sensitivity")
  func filtersBookingsByEventTitle() throws {
    let start = try date("2026-12-24T09:00:00Z")
    let bookings = [
      makeBooking(title: "DevSoc Annual General Meeting", start: start),
      makeBooking(title: "COMP1511 Lecture", start: start),
      makeBooking(title: "devsoc Workshop", start: start),
    ]

    let results = BookingSearch.filter(bookings, query: "DevSoc")

    #expect(results.map(\.title) == ["DevSoc Annual General Meeting", "devsoc Workshop"])
  }

  @Test("Blank event search preserves all bookings")
  func blankSearchPreservesBookings() throws {
    let start = try date("2026-12-24T09:00:00Z")
    let bookings = [
      makeBooking(title: "DevSoc Workshop", start: start),
      makeBooking(title: "Lecture", start: start),
    ]

    #expect(BookingSearch.filter(bookings, query: "   ") == bookings)
  }

  @Test("Location text omits a missing building cleanly")
  func optionalBuildingPresentation() throws {
    let booking = makeBooking(
      title: "No building",
      start: try date("2026-12-24T09:00:00Z"),
      buildingName: nil)

    #expect(BookingFormatting.locationDescription(for: booking).0 == booking.roomName)
  }

  @Test("A cross-midnight booking includes end-date context")
  func crossMidnightFormatting() throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let start = try date("2026-12-24T23:00:00Z")
    let booking = WeeklyBooking(
      title: "Overnight",
      bookingType: "BLOCK",
      roomID: "K17-LG01",
      roomName: "Ainsworth LG01",
      buildingID: "K17",
      buildingName: "Ainsworth Building",
      start: start,
      end: try date("2026-12-25T01:00:00Z"),
      usage: "TUSM",
      capacity: 50,
      abbreviation: "TETBLG03")

    let description = BookingFormatting.timeRange(for: booking, calendar: calendar)

    #expect(description.contains("–"))
    #expect(description != "")
  }

  // MARK: Private

  private func makeBooking(
    title: String,
    start: Date,
    buildingName: String? = "Ainsworth Building")
    -> WeeklyBooking
  {
    WeeklyBooking(
      title: title,
      bookingType: "BLOCK",
      roomID: "K17-LG01",
      roomName: "Ainsworth LG01",
      buildingID: buildingName == nil ? nil : "K17",
      buildingName: buildingName,
      start: start,
      end: start.addingTimeInterval(60 * 60),
      usage: "TUSM",
      capacity: 50,
      abbreviation: "TETBLG03")
  }

  private func date(_ value: String) throws -> Date {
    try #require(ISO8601DateFormatter().date(from: value))
  }
}
