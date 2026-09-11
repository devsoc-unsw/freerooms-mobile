//
//  BookingService.swift
//  Bookings
//
//  Created by Yanlin Li  on 7/8/2025.
//

import BookingModels
import Foundation
import VISOR

public typealias GetWeeklyBookingsResult = Result<[WeeklyBooking], FetchWeeklyBookingsError>

// MARK: - FetchWeeklyBookingsError

/// Feature-level failures that can be presented or recovered from by the Bookings UI.
public enum FetchWeeklyBookingsError: Error, Equatable, Sendable {
  case connectivity
  case invalidResponse
  case invalidDateFormat
  case invalidDateRange
  case cancelled
}

extension FetchWeeklyBookingsError {
  public var clientMessage: String {
    switch self {
    case .connectivity:
      "Could not load this week's bookings. Please check your internet connection and try again."
    case .invalidResponse:
      "The bookings service returned an unexpected response. Please try again."
    case .invalidDateFormat:
      "Some bookings contained invalid dates. Please try again later."
    case .invalidDateRange:
      "The current week could not be determined."
    case .cancelled:
      "The bookings request was cancelled."
    }
  }
}

// MARK: - BookingService

@Stubbable
public protocol BookingService {
  func getWeeklyBookings(in interval: DateInterval) async -> GetWeeklyBookingsResult
}

// MARK: - LiveBookingService

public final class LiveBookingService: BookingService {

  // MARK: Lifecycle

  public init(loader: any WeeklyBookingLoader) {
    self.loader = loader
  }

  // MARK: Public

  public func getWeeklyBookings(in interval: DateInterval) async -> GetWeeklyBookingsResult {
    switch await loader.fetch(in: interval) {
    case .success(let bookings):
      .success(bookings)
    case .failure(let error):
      .failure(FetchWeeklyBookingsError(error))
    }
  }

  // MARK: Private

  private let loader: any WeeklyBookingLoader
}

// MARK: - PreviewBookingService

public final class PreviewBookingService: BookingService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getWeeklyBookings(in interval: DateInterval) async -> GetWeeklyBookingsResult {
    let firstStart = interval.start.addingTimeInterval(10 * 60 * 60)
    let secondStart = interval.start.addingTimeInterval(24 * 60 * 60 + 14 * 60 * 60)

    return .success([
      WeeklyBooking(
        title: "COMP1511 Lecture",
        bookingType: "BLOCK",
        roomID: "K17-LG01",
        roomName: "Ainsworth LG01",
        buildingID: "K17",
        buildingName: "Ainsworth Building",
        start: firstStart,
        end: firstStart.addingTimeInterval(2 * 60 * 60),
        usage: "LCTR",
        capacity: 472,
        abbreviation: "AinsworthLG01"),
      WeeklyBooking(
        title: "CSE Society Workshop",
        bookingType: "BLOCK",
        roomID: "K17-G01",
        roomName: "Ainsworth G01",
        buildingID: "K17",
        buildingName: "Ainsworth Building",
        start: secondStart,
        end: secondStart.addingTimeInterval(90 * 60),
        usage: "TUSM",
        capacity: 50,
        abbreviation: "AinsworthG01"),
    ])
  }
}

extension FetchWeeklyBookingsError {
  fileprivate init(_ error: WeeklyBookingLoaderError) {
    switch error {
    case .connectivity:
      self = .connectivity
    case .invalidResponse:
      self = .invalidResponse
    case .invalidDateFormat:
      self = .invalidDateFormat
    case .invalidDateRange:
      self = .invalidDateRange
    case .cancelled:
      self = .cancelled
    }
  }
}
