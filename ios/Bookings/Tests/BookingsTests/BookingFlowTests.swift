//
//  BookingFlowTests.swift
//  BookingsTests
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingInteractors
import BookingServices
import BookingTestUtils
import Foundation
import Testing

@Suite
struct BookingFlowTests {

  // MARK: Internal

  @Test("Service preserves every loader error", arguments: [
    (WeeklyBookingLoaderError.connectivity, FetchWeeklyBookingsError.connectivity),
    (.invalidResponse, .invalidResponse),
    (.invalidDateFormat, .invalidDateFormat),
    (.invalidDateRange, .invalidDateRange),
    (.cancelled, .cancelled),
  ])
  func servicePreservesError(
    loaderError: WeeklyBookingLoaderError,
    expected: FetchWeeklyBookingsError)
    async
  {
    let loader = StubWeeklyBookingLoader()
    loader.fetchReturnValue = .failure(loaderError)
    let service = LiveBookingService(loader: loader)
    let result = await service.getWeeklyBookings(in: standardWeek)
    #expect(result == .failure(expected))
  }

  @Test("Interactor calculates the requested device-calendar week")
  func interactorCalculatesCalendarWeek() throws {
    let interactor = BookingInteractor(service: StubBookingService())
    let referenceDate = try #require(parseDate("2026-10-01T12:00:00+10:00"))
    let calendar = makeSydneyCalendar()

    let interval = try interactor.weekInterval(containing: referenceDate, calendar: calendar).get()

    #expect(interval.contains(referenceDate))
    #expect(interval == calendar.dateInterval(of: .weekOfYear, for: referenceDate))
    #expect(interval.duration != 7 * 24 * 60 * 60)
  }

  @Test("Week calculation remains correct across a calendar-year boundary")
  func interactorCalculatesYearBoundaryWeek() throws {
    let interactor = BookingInteractor(service: StubBookingService())
    let referenceDate = try #require(parseDate("2027-01-01T12:00:00+11:00"))
    let calendar = makeSydneyCalendar()

    let interval = try interactor.weekInterval(containing: referenceDate, calendar: calendar).get()

    #expect(interval.contains(referenceDate))
    #expect(interval.start < referenceDate)
    #expect(interval.end > referenceDate)
  }

  // MARK: Private

  private var standardWeek: DateInterval {
    DateInterval(
      start: parseDate("2026-12-21T00:00:00Z")!,
      end: parseDate("2026-12-28T00:00:00Z")!)
  }

  private func makeSydneyCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_AU")
    calendar.timeZone = TimeZone(identifier: "Australia/Sydney")!
    return calendar
  }

  private func parseDate(_ value: String) -> Date? {
    ISO8601DateFormatter().date(from: value)
  }
}
