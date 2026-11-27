//
//  BookingService.swift
//  Bookings
//
//  Created by Yanlin Li  on 7/8/2025.
//

public import BookingModels
public import Foundation
import VISOR
public import VISORTestDoubles
public import Apollo
import DevSocAPI

@GenerateSpy(.sendable)
@GenerateStub(.sendable)
public protocol BookingService: AnyObject, Sendable {
  func getWeeklyBookings(in interval: DateInterval) async throws -> [WeeklyBooking]
}

public final actor ApolloBookingService: BookingService {
  private let client: ApolloClient
  
  private var cachedBookings: [WeeklyBooking]?
  
  public init(client: ApolloClient) {
    self.client = client
  }
  
  public func getWeeklyBookings(in interval: DateInterval) async throws -> [WeeklyBooking] {
    let dateFormat = Date.ISO8601FormatStyle()
    
    #warning(
      """
      Uses the first date interval provided, and then returns the same results.
      This Loader should be full replaced with a backend implementation instead of calling Hasuragres directly.
      """
    )
    
    // Check if we have some saved bookings
    if let cachedBookings {
      return cachedBookings
    }
    
    // Create the GraphQL Query
    let query = WeeklyBookingsQuery(
      weekStart: dateFormat.format(interval.start),
      weekEnd: dateFormat.format(interval.end))
    
    let result: GraphQLResponse<WeeklyBookingsQuery>
    do {
      result = try await client.fetch(query: query)
    } catch let error as CancellationError {
      // Rethrow Swift Concurrency CancellationErrors
      throw error
    } catch ApolloClient.Error.noResults {
      // Just return empty bookings in this case
      return []
    }
    
    // Convert fetched bookings into WeeklyBookings
    guard let data = result.data else {
      throw BookingServiceError.noBookings
    }
    
    return data.bookings.compactMap {
      
      // Convert start and end timestamps if possible
      guard let start = try? dateFormat.parse($0.start),
            let end = try? dateFormat.parse($0.end) else { return nil }
      
      // Create WeeklyBooking from GraphQL bookings
      return WeeklyBooking(
        title: $0.name,
        bookingType: $0.bookingType,
        roomID: $0.roomId,
        roomName: $0.room.name,
        buildingID: $0.room.building.id,
        buildingName: $0.room.building.name,
        start: start,
        end: end,
        usage: $0.room.usage,
        capacity: $0.room.capacity,
        abbreviation: $0.room.abbr,
        accessibility: $0.room.accessibility,
        audioVisual: $0.room.audiovisual,
        infoTechnology: $0.room.infotechnology,
        microphone: $0.room.microphone,
        service: $0.room.service,
        writingMedia: $0.room.writingMedia)
    }
  }
}

public final class FixedBookingService: BookingService {
  public let bookings: [WeeklyBooking]
  
  public init(bookings: [WeeklyBooking]) {
    self.bookings = bookings
  }
  
  public func getWeeklyBookings(in internal: DateInterval) async throws -> [WeeklyBooking] {
    return bookings
  }
}

/// Errors that can occur when fetching bookings
public enum BookingServiceError: Error, LocalizedError {
  
  /// Could not find any ``WeeklyBooking``s
  case noBookings
  
  public var errorDescription: String? {
    switch self {
    case .noBookings:
      "No bookings found"
    }
  }
  
}

/*

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

@GenerateStub
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
        abbreviation: "AinsworthLG01",
        accessibility: [
          "Ventilation - Air conditioning",
          "Weekend Access",
          "Wheelchair access - teaching",
          "Wheelchair access - student",
          "Power at Wall",
        ],
        audioVisual: [
          "Document camera",
        ],
        infoTechnology: [
          "Hybrid Teaching Space",
          "Lecture capture venue",
          "Lecture capture with video feed",
          "Interactive Learning Space (High Tech)",
          "IT laptop connection",
          "IT Lectern",
          "Video data projector",
        ],
        microphone: [
          "Dual Radio Microphones",
          "Lectern (fixed)",
          "Radio microphone",
        ],
        service: [],
        writingMedia: [
          "Blackboard",
          "Whiteboard",
        ]),
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
        abbreviation: "AinsworthG01",
        accessibility: [
          "Ventilation - Air conditioning",
          "Wheelchair access - teaching",
          "Wheelchair access - student",
        ],
        audioVisual: [
          "Document camera",
        ],
        infoTechnology: [
          "IT laptop connection",
          "IT Lectern",
          "Video data projector",
          "Web Camera with Microphone",
        ],
        microphone: [
          "IT laptop connection",
          "IT Lectern",
          "Video data projector",
          "Web Camera with Microphone",
        ],
        service: [],
        writingMedia: [
          "Whiteboard",
        ]),
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

*/
