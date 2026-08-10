//
//  BookingViewModel.swift
//  Bookings
//
//  Created by Yanlin Li  on 8/8/2025.
//

import BookingInteractors
import BookingModels
import BookingServices
import Foundation
import Observation

// MARK: - BookingPresentationError

/// Stable, UI-ready error content exposed by the booking view model.
public struct BookingPresentationError: Identifiable, Equatable, Sendable {
  public init(title: String = "Error", message: String) {
    self.title = title
    self.message = message
  }

  public let title: String
  public let message: String

  public var id: String {
    "\(title)|\(message)"
  }
}

// MARK: - BookingViewModel

@MainActor
public protocol BookingViewModel: AnyObject {
  var bookings: [WeeklyBooking] { get }
  var isLoading: Bool { get }
  var errorMessage: BookingPresentationError? { get set }
  var loadedWeekInterval: DateInterval? { get }

  func loadCurrentWeekBookings(
    referenceDate: Date,
    calendar: Calendar,
    forceRefresh: Bool)
    async
}

// MARK: - LiveBookingViewModel

@MainActor
@Observable
public class LiveBookingViewModel: BookingViewModel {

  // MARK: Lifecycle

  public init(interactor: any BookingInteracting) {
    self.interactor = interactor
  }

  // MARK: Public

  public private(set) var bookings = [WeeklyBooking]()
  public private(set) var isLoading = false
  public var errorMessage: BookingPresentationError?
  public private(set) var loadedWeekInterval: DateInterval?

  public func loadCurrentWeekBookings(
    referenceDate: Date = Date(),
    calendar: Calendar = .current,
    forceRefresh: Bool = false)
    async
  {
    guard !isLoading else { return }

    let requestedInterval: DateInterval
    switch interactor.weekInterval(containing: referenceDate, calendar: calendar) {
    case .success(let interval):
      requestedInterval = interval
    case .failure(let error):
      errorMessage = BookingPresentationError(message: error.clientMessage)
      return
    }

    // A successful result is reusable only for the exact calendar interval that produced it.
    guard forceRefresh || loadedWeekInterval != requestedInterval else { return }

    if loadedWeekInterval != requestedInterval {
      bookings = []
    }

    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    switch await interactor.getWeeklyBookings(in: requestedInterval) {
    case .success(let bookings):
      self.bookings = bookings
      loadedWeekInterval = requestedInterval

    case .failure(.cancelled):
      break

    case .failure(let error):
      errorMessage = BookingPresentationError(message: error.clientMessage)
    }
  }

  // MARK: Private

  private let interactor: any BookingInteracting
}

// MARK: - PreviewBookingViewModel

public final class PreviewBookingViewModel: LiveBookingViewModel {
  public init() {
    super.init(interactor: BookingInteractor(service: PreviewBookingService()))
  }
}
