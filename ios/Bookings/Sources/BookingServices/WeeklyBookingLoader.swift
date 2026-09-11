//
//  WeeklyBookingLoader.swift
//  Bookings
//
//  Created by Yanlin Li  on 7/8/2025.
//

import Apollo
import ApolloAPI
import BookingModels
import DevSocAPI
import Foundation
import OSLog
import VISOR

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
@Stubbable
public protocol WeeklyBookingLoader {
  func fetch(in interval: DateInterval) async -> Result<[WeeklyBooking], WeeklyBookingLoaderError>
}

// MARK: - LiveGraphQLWeeklyBookingLoader

/// Executes the generated weekly GraphQL operation and maps it into app-owned models.
nonisolated public final class LiveGraphQLWeeklyBookingLoader: WeeklyBookingLoader, Sendable {

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

    var bookings = [WeeklyBooking]()
    bookings.reserveCapacity(graphQLBookings.count)

    for graphQLBooking in graphQLBookings {
      guard
        let start = Self.parse(graphQLBooking.start),
        let end = Self.parse(graphQLBooking.end),
        start < end
      else {
        Self.logger.warning("Weekly booking contained an invalid date range")
        return .failure(.invalidDateFormat)
      }

      bookings.append(WeeklyBooking(
        title: graphQLBooking.name,
        bookingType: graphQLBooking.bookingType,
        roomID: graphQLBooking.roomId,
        roomName: graphQLBooking.room.name,
        buildingID: graphQLBooking.room.building.id,
        buildingName: graphQLBooking.room.building.name,
        start: start,
        end: end,
        usage: graphQLBooking.room.usage,
        capacity: graphQLBooking.room.capacity,
        abbreviation: graphQLBooking.room.abbr))
    }

    return .success(bookings.sorted { $0.start < $1.start })
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

  /// The backend currently emits ISO-8601 timestamps both with and without fractional seconds.
  private static func parse(_ value: String) -> Date? {
    let fractionalFormatter = ISO8601DateFormatter()
    fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

    if let date = fractionalFormatter.date(from: value) {
      return date
    }

    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter.date(from: value)
  }
}
