//
//  IncrementalBookingsViewModel.swift
//  Bookings
//
//  Created by Matthew Yuen on 1/10/2026.
//

public import BookingModels
public import VISORTestDoubles

/// How many bookings to fetch at once
private let batchSize: Int = 100

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
  func fetchNextPage() async -> [WeeklyBooking]
  
  /// Fetches all remaining bookings
  func fetchRemainingBookings() async -> [WeeklyBooking]
  
}
