//
//  FilterRoomLoader.swift
//  Rooms
//
//  Created by Yanlin Li  on 17/4/2026.
//

import Foundation
import Networking
import RoomModels
import VISOR

// MARK: - FilterRoomServiceError

public enum FilterRoomServiceError: Error, Equatable {
  case connectivity
  case invalidData
  case invalidURL
}

// MARK: - FilterRoomService

@Spyable
@Stubbable
public protocol FilterRoomService {

  /// Fetches rooms that match the provided filter conditions.
  ///
  /// Use this Loader to retrieve rooms based on booking time, building,
  /// capacity, duration, usage type, and location.
  ///
  /// - Parameters:
  ///   - dateTime: The date to search for available rooms.
  ///   - startTime: The requested booking start time.
  ///   - endTime: The requested booking end time.
  ///   - buildingId: The identifier of the building to filter rooms by.
  ///   - capacity: The minimum room capacity required.
  ///   - duration: The requested booking duration.
  ///   - usage: The intended room usage type.
  ///   - location: The location or campus area to filter rooms by.
  ///   - SortedBySpecificSchoolId: A flag used to filter by a specific school (non-CATS)
  ///
  /// - Returns: A result containing either the filtered rooms or a
  ///   `FilterRoomServiceError` if the request fails.
  func fetchFilteredRooms(options: FilterRoomOptions)
    async -> Result<[String], FilterRoomServiceError>
}

// MARK: - LiveFilterRoomService

/// Provides the current filtered room
public final class LiveFilterRoomService: FilterRoomService {

  // MARK: Lifecycle

  public init(client: HTTPClient, baseURL: URL, endpointPath: String = "api/rooms/search") {
    self.client = client
    self.baseURL = baseURL
    self.endpointPath = endpointPath
  }

  // MARK: Public

  public func fetchFilteredRooms(options: FilterRoomOptions)
    async -> Result<[String], FilterRoomServiceError>
  {
    // Construct the search URL with query parameters based on the provided filter conditions
    guard
      let url = makeSearchRoomsURL(options: options)
    else {
      return .failure(.invalidURL)
    }

    // Create a NetworkCodableLoader to perform the GET request and decode the response into an array of RemoteFilterRoomMap
    let loader = NetworkCodableLoader<RemoteFilterRoomMap>(client: client, url: url)

    switch await loader.fetch() {
    case .success(let response):
      let roomIds = Array(response.keys)

      return .success(roomIds)

    case .failure:
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private let client: HTTPClient
  private let baseURL: URL
  private let endpointPath: String

  /// Helper method to construct the search URL with query parameters.
  ///
  /// Nil and empty-string fields are intentionally omitted from the query
  /// string. The backend returns HTTP 400 when it receives a parameter with
  /// an empty value (e.g. `startTime=`), so we only include fields the user
  /// actually selected. `sortedBySpecificSchoolId` is sent only when `true`.
  private func makeSearchRoomsURL(options: FilterRoomOptions) -> URL? {
    guard
      let baseEndpointURL = URL(string: endpointPath, relativeTo: baseURL),
      var components = URLComponents(url: baseEndpointURL, resolvingAgainstBaseURL: true)
    else {
      return nil
    }

    let candidates: [(String, String?)] = [
      ("datetime", options.dateTime),
      ("startTime", options.startTime),
      ("endTime", options.endTime),
      ("buildingId", options.buildingId),
      ("capacity", options.capacity.map(String.init)),
      ("duration", options.duration.map(String.init)),
      ("usage", options.usage),
      ("location", options.location),
      ("id", options.sortedBySpecificSchoolId ? "true" : nil),
    ]

    let items = candidates.compactMap { name, value -> URLQueryItem? in
      guard let value, !value.isEmpty else { return nil }
      return URLQueryItem(name: name, value: value)
    }

    components.queryItems = items.isEmpty ? nil : items

    return components.url
  }

}
