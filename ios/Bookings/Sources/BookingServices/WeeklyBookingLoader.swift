//
//  WeeklyBookingLoader.swift
//  Bookings
//
//  Created by Yanlin Li  on 7/8/2025.
//

public import Apollo
import ApolloAPI
public import BookingModels
import DevSocAPI
public import Foundation
import OSLog
import VISOR
public import VISORTestDoubles

// MARK: - WeeklyBookingLoaderError

/// Failures produced at the GraphQL transport and response boundary.
public enum WeeklyBookingLoaderError: Error, Equatable, Sendable {
  case connectivity
  case invalidResponse
  case invalidDateFormat
  case invalidDateRange
  case cancelled
}

// MARK: - WeeklyBookingLoader

/// Loads bookings that overlap a supplied calendar interval.
@GenerateStub
public protocol WeeklyBookingLoader {
  func fetch(in interval: DateInterval) async -> Result<[WeeklyBooking], WeeklyBookingLoaderError>
}

// MARK: - LiveGraphQLWeeklyBookingLoader

/// Executes the generated weekly GraphQL operation and maps it into app-owned models.
public final class LiveGraphQLWeeklyBookingLoader: WeeklyBookingLoader, Sendable {

  // MARK: Lifecycle

  public init(client: ApolloClient) {
    self.client = client
  }

  // MARK: Public

  public func fetch(in interval: DateInterval) async -> Result<[WeeklyBooking], WeeklyBookingLoaderError> {
    guard interval.duration > 0 else {
      return .failure(.invalidDateRange)
    }

    let query = WeeklyBookingsQuery(
      weekStart: Self.encode(interval.start),
      weekEnd: Self.encode(interval.end))

    let response: GraphQLResponse<WeeklyBookingsQuery>
    do {
      response = try await client.fetch(query: query, cachePolicy: .networkOnly)
    } catch is CancellationError {
      return .failure(.cancelled)
    } catch let error as URLError where error.code == .cancelled {
      // URLSession can represent structured-concurrency cancellation as a cancelled URL request.
      return .failure(.cancelled)
    } catch is URLError {
      return .failure(.connectivity)
    } catch is JSONDecodingError {
      return .failure(.invalidResponse)
    } catch is JSONResponseParsingError {
      return .failure(.invalidResponse)
    } catch is GraphQLExecutionError {
      return .failure(.invalidResponse)
    } catch is ResponseCodeInterceptor.ResponseCodeError {
      return .failure(.connectivity)
    } catch {
      Self.logger.warning("Weekly bookings request failed: \(error)")
      return .failure(.connectivity)
    }

    guard response.errors?.isEmpty != false, let graphQLBookings = response.data?.bookings else {
      Self.logger.warning("Weekly bookings response contained GraphQL errors or no data")
      return .failure(.invalidResponse)
    }

    do throws(BookingConversionError) {
      let bookings = try graphQLBookings.map(Booking.init(from:))

      // FIXME: Problem with duplicate ids?
      assert({
        var seenIds = Set<Booking.ID>(minimumCapacity: bookings.count)
        var duplicates = Set<Booking.ID>()
        
        for b in bookings {
          guard !seenIds.contains(b.id) else {
            duplicates.insert(b.id)
            continue
          }
          seenIds.insert(b.id)
        }
        
        guard duplicates.isEmpty else {
          Self.logger.fault(
            """
            \(#function): Duplicate IDs found for Bookings!
            \(duplicates)
            """)
          return false
        }
        
        return true
      }(), "Duplicate id detected for bookings")

      return .success(bookings)
    } catch {
      switch error {
      case .invalidDateFormat:
        Self.logger.warning("Weekly booking contained an invalid date range")
        return .failure(.invalidDateFormat)

      case .invalidEventId:
        Self.logger.warning("Weekly booking contained an invalid event ID")
        return .failure(.invalidResponse)

      case .invalidOccurrenceId:
        Self.logger.warning("Weekly booking contained an invalid occurrence ID")
        return .failure(.invalidResponse)
      }
    }
  }

  // MARK: Private

  private static let logger = Logger(
    subsystem: "com.devsoc.Freerooms.Bookings",
    category: "LiveGraphQLWeeklyBookingLoader")

  private let client: ApolloClient

  /// Query boundaries are normalized to UTC while retaining the same absolute instants.
  private static func encode(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter.string(from: date)
  }

}
