//
//  BookingInteractor.swift
//  Bookings
//
//  Created by Yanlin Li  on 7/8/2025.
//

import BookingModels
import BookingServices
import Foundation
import VISOR

// MARK: - BookingInteracting

/// Defines the calendar and service policies needed by the weekly Bookings view model.
@Spyable
public protocol BookingInteracting {
  func weekInterval(
    containing referenceDate: Date,
    calendar: Calendar)
    -> Result<DateInterval, FetchWeeklyBookingsError>

  func getWeeklyBookings(in interval: DateInterval) async -> GetWeeklyBookingsResult
}

// MARK: - BookingInteractor

public final class BookingInteractor: BookingInteracting {

  // MARK: Lifecycle

  public init(service: any BookingService) {
    self.service = service
  }

  // MARK: Public

  /// Uses the supplied device calendar so locale, time zone, and daylight-saving rules are respected.
  public func weekInterval(
    containing referenceDate: Date,
    calendar: Calendar)
    -> Result<DateInterval, FetchWeeklyBookingsError>
  {
    guard let interval = calendar.dateInterval(of: .weekOfYear, for: referenceDate) else {
      return .failure(.invalidDateRange)
    }
    return .success(interval)
  }

  public func getWeeklyBookings(in interval: DateInterval) async -> GetWeeklyBookingsResult {
    await service.getWeeklyBookings(in: interval)
  }

  // MARK: Private

  private let service: any BookingService
}
