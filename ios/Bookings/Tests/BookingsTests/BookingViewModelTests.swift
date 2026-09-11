//
//  BookingViewModelTests.swift
//  BookingsTests
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingInteractors
import BookingServices
import BookingTestUtils
import BookingViewModels
import Foundation
import Testing

// MARK: - BookingViewModelTests

@MainActor
@Suite
struct BookingViewModelTests {

  // MARK: Internal

  @Test("Successful and empty responses become reusable same-week results", arguments: [true, false])
  func successfulResultIsReused(hasBooking: Bool) async {
    let expected = hasBooking ? [BookingFixtures.weeklyBooking()] : []
    let interactor = SpyBookingInteracting()
    interactor.weekIntervalReturnValue = .success(firstWeek)
    interactor.getWeeklyBookingsReturnValue = .success(expected)
    let viewModel = LiveBookingViewModel(interactor: interactor)

    await viewModel.loadCurrentWeekBookings(referenceDate: firstWeek.start, calendar: .current, forceRefresh: false)
    await viewModel.loadCurrentWeekBookings(referenceDate: firstWeek.start, calendar: .current, forceRefresh: false)

    #expect(viewModel.bookings == expected)
    #expect(viewModel.loadedWeekInterval == firstWeek)
    #expect(interactor.getWeeklyBookingsCallCount == 1)
  }

  @Test("Explicit refresh fetches again and retains stale data on failure")
  func refreshRetainsDataOnFailure() async {
    let booking = BookingFixtures.weeklyBooking()
    let interactor = SpyBookingInteracting()
    interactor.weekIntervalReturnValue = .success(firstWeek)
    interactor.getWeeklyBookingsReturnValue = .success([booking])
    let viewModel = LiveBookingViewModel(interactor: interactor)
    await viewModel.loadCurrentWeekBookings(referenceDate: firstWeek.start, calendar: .current, forceRefresh: false)

    interactor.getWeeklyBookingsReturnValue = .failure(.connectivity)
    await viewModel.loadCurrentWeekBookings(referenceDate: firstWeek.start, calendar: .current, forceRefresh: true)

    #expect(viewModel.bookings == [booking])
    #expect(viewModel.errorMessage?.message == FetchWeeklyBookingsError.connectivity.clientMessage)
    #expect(interactor.getWeeklyBookingsCallCount == 2)
  }

  @Test("A different week clears old data and fetches again")
  func weekRolloverFetchesAgain() async {
    let interactor = SpyBookingInteracting()
    interactor.weekIntervalReturnValue = .success(firstWeek)
    interactor.getWeeklyBookingsReturnValue = .success([BookingFixtures.weeklyBooking()])
    let viewModel = LiveBookingViewModel(interactor: interactor)
    await viewModel.loadCurrentWeekBookings(referenceDate: firstWeek.start, calendar: .current, forceRefresh: false)

    interactor.weekIntervalReturnValue = .success(secondWeek)
    interactor.getWeeklyBookingsReturnValue = .success([])
    await viewModel.loadCurrentWeekBookings(referenceDate: secondWeek.start, calendar: .current, forceRefresh: false)

    #expect(viewModel.bookings.isEmpty)
    #expect(viewModel.loadedWeekInterval == secondWeek)
    #expect(interactor.getWeeklyBookingsCallCount == 2)
  }

  @Test("Cancellation does not expose a user-visible error")
  func cancellationIsInvisible() async {
    let interactor = SpyBookingInteracting()
    interactor.weekIntervalReturnValue = .success(firstWeek)
    interactor.getWeeklyBookingsReturnValue = .failure(.cancelled)
    let viewModel = LiveBookingViewModel(interactor: interactor)

    await viewModel.loadCurrentWeekBookings(referenceDate: firstWeek.start, calendar: .current, forceRefresh: false)

    #expect(viewModel.errorMessage == nil)
    #expect(!viewModel.isLoading)
  }

  @Test("Simultaneous calls produce only one fetch")
  func duplicateLoadIsPrevented() async {
    let interactor = SuspendingBookingInteractor(interval: firstWeek)
    let viewModel = LiveBookingViewModel(interactor: interactor)

    let firstLoad = Task {
      await viewModel.loadCurrentWeekBookings(referenceDate: firstWeek.start, calendar: .current, forceRefresh: false)
    }
    while interactor.getWeeklyBookingsCallCount == 0 {
      await Task.yield()
    }

    await viewModel.loadCurrentWeekBookings(referenceDate: firstWeek.start, calendar: .current, forceRefresh: true)
    #expect(interactor.getWeeklyBookingsCallCount == 1)

    interactor.resume()
    await firstLoad.value
  }

  // MARK: Private

  private var firstWeek: DateInterval {
    DateInterval(
      start: Date(timeIntervalSince1970: 1_798_070_400),
      duration: 7 * 24 * 60 * 60)
  }

  private var secondWeek: DateInterval {
    DateInterval(
      start: firstWeek.end,
      duration: 7 * 24 * 60 * 60)
  }
}

// MARK: - SuspendingBookingInteractor

/// A concurrency-specific double; VISOR spies intentionally return immediately and cannot hold an in-flight request open.
@MainActor
private final class SuspendingBookingInteractor: BookingInteracting {

  // MARK: Lifecycle

  init(interval: DateInterval) {
    self.interval = interval
  }

  // MARK: Internal

  private(set) var getWeeklyBookingsCallCount = 0

  func weekInterval(
    containing _: Date,
    calendar _: Calendar)
    -> Result<DateInterval, FetchWeeklyBookingsError>
  {
    .success(interval)
  }

  func getWeeklyBookings(in _: DateInterval) async -> GetWeeklyBookingsResult {
    getWeeklyBookingsCallCount += 1
    while isSuspended {
      await Task.yield()
    }
    return .success([])
  }

  func resume() {
    isSuspended = false
  }

  // MARK: Private

  private let interval: DateInterval
  private var isSuspended = true
}
