//
//  File.swift
//  Rooms
//
//  Created by Yanlin Li  on 17/4/2026.
//

import Foundation
import Networking
import RoomModels
import VISOR

// MARK: - FilterRoomLoaderError

public enum FilterRoomLoaderError: Error, Equatable {
  case connectivity
  case invalidData
  case invalidURL
}

// MARK: - FilterRoomLoader

@Spyable
@Stubbable
public protocol FilterRoomLoader {

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
  ///   `FilterRoomLoaderError` if the request fails.
  func fetchFilteredRooms(
    dateTime: String?,
    startTime: String?,
    endTime: String?,
    buildingId: String?,
    capacity: Int?,
    duration: Int?,
    usage: String?,
    location: String?,
    SortedBySpecificSchoolId: Bool)
    async -> Result<[String], FilterRoomLoaderError>
}

// MARK: - LiveFilterRoomLoader

/// Provides the current filtered room
public final class LiveFilterRoomLoader: FilterRoomLoader {

  // MARK: Lifecycle

  public init(client: HTTPClient, baseURL: URL, endpointPath: String = "api/rooms/search") {
    self.client = client
    self.baseURL = baseURL
    self.endpointPath = endpointPath
  }

  // MARK: Public

  public func fetchFilteredRooms(
    dateTime: String?,
    startTime: String?,
    endTime: String?,
    buildingId: String?,
    capacity: Int?,
    duration: Int?,
    usage: String?,
    location: String?,
    SortedBySpecificSchoolId: Bool)
    async -> Result<[String], FilterRoomLoaderError>
  {
    // Construct the search URL with query parameters based on the provided filter conditions
    guard
      let url = makeSearchRoomsURL(
        dateTime: dateTime,
        startTime: startTime,
        endTime: endTime,
        buildingId: buildingId,
        capacity: capacity,
        duration: duration,
        usage: usage,
        location: location,
        SortedBySpecificSchoolId: SortedBySpecificSchoolId)
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

  /// Helper method to construct the search URL with query parameters
  private func makeSearchRoomsURL(
    dateTime: String?,
    startTime: String?,
    endTime: String?,
    buildingId: String?,
    capacity: Int?,
    duration: Int?,
    usage: String?,
    location: String?,
    SortedBySpecificSchoolId: Bool)
    -> URL?
  {
    // Construct the base endpoint URL and append query parameters for filtering rooms
    guard
      let baseEndpointURL = URL(string: endpointPath, relativeTo: baseURL),
      var components = URLComponents(url: baseEndpointURL, resolvingAgainstBaseURL: true)
    else {
      return nil
    }

    // Add query items for each filter parameter, using empty strings for nil values and converting boolean to "true"/"false"
    components.queryItems = [
      URLQueryItem(name: "datetime", value: dateTime ?? ""),
      URLQueryItem(name: "startTime", value: startTime ?? ""),
      URLQueryItem(name: "endTime", value: endTime ?? ""),
      URLQueryItem(name: "buildingId", value: buildingId ?? ""),
      URLQueryItem(name: "capacity", value: capacity.map(String.init) ?? ""),
      URLQueryItem(name: "duration", value: duration.map(String.init) ?? ""),
      URLQueryItem(name: "usage", value: usage ?? ""),
      URLQueryItem(name: "location", value: location ?? ""),
      URLQueryItem(name: "id", value: SortedBySpecificSchoolId ? "true" : "false"),
    ]

    // Return the fully constructed URL with query parameters
    return components.url
  }

}
