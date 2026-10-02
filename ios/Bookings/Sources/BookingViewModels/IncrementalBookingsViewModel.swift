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
  var bookings: [WeeklyBooking.ID : WeeklyBooking] { get }

  /// If there are more bookings to fetch
  var hasMoreBookings: Bool { get }

  /// Fetch the next page of bookings
  @discardableResult
  func fetchNextPage() async throws -> [WeeklyBooking.ID]

  /// Fetches all remaining bookings
  @discardableResult
  func fetchRemainingBookings() async throws -> [WeeklyBooking.ID]

}

@MainActor
@Observable
public final class ListIncrementalBookingsViewModel {
  public private(set) var isFetching: Bool = false
  public private(set) var bookings: [WeeklyBooking.ID : WeeklyBooking] = [:]
  public private(set) var hasMoreBookings: Bool = false
  
  public func fetchNextPage() async throws -> [WeeklyBooking.ID] {
    fatalError()
    
  }
  
  public func fetchRemainingBookings() async throws -> [WeeklyBooking.ID] {
    fatalError()
  }
  
}
