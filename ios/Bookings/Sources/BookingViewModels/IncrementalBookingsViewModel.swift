//
//  IncrementalBookingsViewModel.swift
//  Bookings
//
//  Created by Matthew Yuen on 1/10/2026.
//

public import BookingModels
public import VISORTestDoubles

// MARK: - IncrementalBookingsViewModel

@GenerateSpy
@GenerateStub
public protocol IncrementalBookingsViewModel: AnyObject {

  /// Whether the `ViewModel` is fetching more bookings
  var isFetching: Bool { get }

  /// The currently fetched list of bookings
  var bookings: [WeeklyBooking] { get }

  /// If there are more bookings to fetch
  var hasMoreBookings: Bool { get }

  /// Fetch the next page of bookings
  @discardableResult
  func fetchNextPage() async throws -> [WeeklyBooking.ID]

  /// Fetches all remaining bookings
  @discardableResult
  func fetchRemainingBookings() async throws -> [WeeklyBooking.ID]
  
  /// Get a booking matching the provided id
  ///
  /// This is provided as a customization point to allow fater performance
  /// to get a booking for a given id. The default implementation does a linear search
  /// over ``bookings`` in order to find a matching booking.
  func booking(for id: WeeklyBooking.ID) -> WeeklyBooking?
}

extension IncrementalBookingsViewModel {
  func booking(for id: WeeklyBooking.ID) -> WeeklyBooking? {
    bookings.first { $0.id == id }
  }
}

@Observable
public final class ListIncrementalBookingsViewModel {
  public private(set) var isFetching: Bool = false
  public private(set) var bookings: [WeeklyBooking] = []
  public private(set) var hasMoreBookings: Bool = false
  
  private var _bookingsMap: [WeeklyBooking.ID: WeeklyBooking] = [:]
  
  public func fetchNextPage() async throws -> [WeeklyBooking.ID] {
    fatalError()
  }
  
  public func fetchRemainingBookings() async throws -> [WeeklyBooking.ID] {
    fatalError()
  }
  
  public func booking(for id: WeeklyBooking.ID) -> WeeklyBooking? {
    _bookingsMap[id]
  }
  
}
