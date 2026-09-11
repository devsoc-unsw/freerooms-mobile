//
//  WeeklyBookingLoaderTests.swift
//  BookingsTests
//
//  Created by Yanlin Li  on 8/8/2025.
//

import Apollo
import BookingServices
import DevSocAPI
import Foundation
import NetworkingTestUtils
import Testing

// MARK: - WeeklyBookingLoaderTests

@Suite
struct WeeklyBookingLoaderTests {

  // MARK: Internal

  @Test("Generated query uses end-exclusive interval overlap variables")
  func queryUsesOverlapVariables() throws {
    let query = WeeklyBookingsQuery(
      weekStart: "2026-12-21T00:00:00Z",
      weekEnd: "2026-12-28T00:00:00Z")
    let document = try #require(WeeklyBookingsQuery.operationDocument.definition?.queryDocument)

    #expect(query.weekStart == "2026-12-21T00:00:00Z")
    #expect(query.weekEnd == "2026-12-28T00:00:00Z")
    #expect(document.contains("start: { _lt: $weekEnd }"))
    #expect(document.contains("end: { _gt: $weekStart }"))
  }

  @Test("Maps nested bookings and accepts timestamps with and without fractional seconds")
  func mapsSuccessfulResponse() async throws {
    let dataSource = MockApolloDataSource()
    try await setResponse(
      on: dataSource,
      json: [
        "data": [
          "bookings": [
            bookingJSON(
              name: "Later booking",
              start: "2026-12-24T11:00:00+00:00",
              end: "2026-12-24T12:00:00+00:00"),
            bookingJSON(
              name: "Earlier booking",
              start: "2026-12-24T09:00:00.000Z",
              end: "2026-12-24T10:00:00.500Z"),
          ],
        ],
      ])

    let bookings = try await makeLoader(dataSource).fetch(in: weekInterval).get()

    #expect(bookings.map(\.title) == ["Earlier booking", "Later booking"])
    #expect(bookings.first?.roomID == "K-H6-LG03")
    #expect(bookings.first?.roomName == "Tyree Energy Technology LG03")
    #expect(bookings.first?.buildingID == "K-H6")
    #expect(bookings.first?.buildingName == "Tyree Energy Technologies Building")
  }

  @Test("Malformed or reversed booking dates return a safe failure", arguments: [
    ("not-a-date", "2026-12-24T12:00:00+00:00"),
    ("2026-12-24T13:00:00+00:00", "2026-12-24T12:00:00+00:00"),
  ])
  func invalidBookingDateReturnsFailure(start: String, end: String) async throws {
    let dataSource = MockApolloDataSource()
    try await setResponse(
      on: dataSource,
      json: ["data": ["bookings": [bookingJSON(name: "Bad date", start: start, end: end)]]])

    let result = await makeLoader(dataSource).fetch(in: weekInterval)
    #expect(result == .failure(.invalidDateFormat))
  }

  @Test("An invalid requested interval is rejected before networking")
  func invalidIntervalReturnsFailure() async {
    let dataSource = MockApolloDataSource()
    let date = Date(timeIntervalSince1970: 100)

    let result = await makeLoader(dataSource).fetch(in: DateInterval(start: date, end: date))

    #expect(result == .failure(.invalidDateRange))
  }

  @Test("GraphQL errors return invalid response")
  func graphQLErrorReturnsInvalidResponse() async throws {
    let dataSource = MockApolloDataSource()
    try await setResponse(
      on: dataSource,
      json: ["errors": [["message": "The server rejected the query"]]])

    let result = await makeLoader(dataSource).fetch(in: weekInterval)

    #expect(result == .failure(.invalidResponse))
  }

  @Test("Missing data returns invalid response")
  func missingDataReturnsInvalidResponse() async throws {
    let dataSource = MockApolloDataSource()
    try await setResponse(on: dataSource, json: ["data": NSNull()])

    let result = await makeLoader(dataSource).fetch(in: weekInterval)

    #expect(result == .failure(.invalidResponse))
  }

  @Test("Invalid JSON returns invalid response")
  func invalidJSONReturnsFailure() async {
    let dataSource = MockApolloDataSource()
    let response = HTTPURLResponse(
      url: dataSource.endpoint,
      statusCode: 200,
      httpVersion: nil,
      headerFields: ["Content-Type": "application/json"])!
    await dataSource.session.setResponse(
      response,
      data: Data("not-json".utf8),
      for: WeeklyBookingsQuery.self)

    let result = await makeLoader(dataSource).fetch(in: weekInterval)

    #expect(result == .failure(.invalidResponse))
  }

  @Test("A non-success HTTP status maps to connectivity")
  func httpFailureReturnsConnectivity() async {
    let dataSource = MockApolloDataSource()
    let response = HTTPURLResponse(
      url: dataSource.endpoint,
      statusCode: 503,
      httpVersion: nil,
      headerFields: nil)!
    await dataSource.session.setResponse(
      response,
      data: Data(),
      for: WeeklyBookingsQuery.self)

    let result = await makeLoader(dataSource).fetch(in: weekInterval)

    #expect(result == .failure(.connectivity))
  }

  @Test("Missing transport response maps to connectivity")
  func missingResponseReturnsConnectivity() async {
    let result = await makeLoader(MockApolloDataSource()).fetch(in: weekInterval)
    #expect(result == .failure(.connectivity))
  }

  @Test("A cancelled transport request maps to cancellation")
  func cancelledRequestReturnsCancellation() async {
    let store = ApolloStore()
    let transport = RequestChainNetworkTransport(
      urlSession: CancellingApolloURLSession(),
      interceptorProvider: DefaultInterceptorProvider.shared,
      store: store,
      endpointURL: MockApolloDataSource.defaultEndpoint)
    let client = ApolloClient(networkTransport: transport, store: store)

    let result = await LiveGraphQLWeeklyBookingLoader(client: client).fetch(in: weekInterval)

    #expect(result == .failure(.cancelled))
  }

  // MARK: Private

  private var weekInterval: DateInterval {
    DateInterval(
      start: parseDate("2026-12-21T00:00:00Z")!,
      end: parseDate("2026-12-28T00:00:00Z")!)
  }

  private func makeLoader(_ dataSource: MockApolloDataSource) -> LiveGraphQLWeeklyBookingLoader {
    LiveGraphQLWeeklyBookingLoader(client: dataSource.client)
  }

  private func setResponse(on dataSource: MockApolloDataSource, json: [String: Any]) async throws {
    let response = HTTPURLResponse(
      url: dataSource.endpoint,
      statusCode: 200,
      httpVersion: nil,
      headerFields: ["Content-Type": "application/json"])!
    let data = try JSONSerialization.data(withJSONObject: json)
    await dataSource.session.setResponse(response, data: data, for: WeeklyBookingsQuery.self)
  }

  private func bookingJSON(name: String, start: String, end: String) -> [String: Any] {
    [
      "__typename": "bookings",
      "name": name,
      "bookingType": "BLOCK",
      "roomId": "K-H6-LG03",
      "start": start,
      "end": end,
      "room": [
        "__typename": "rooms",
        "name": "Tyree Energy Technology LG03",
        "building": [
          "__typename": "buildings",
          "id": "K-H6",
          "name": "Tyree Energy Technologies Building",
        ],
        "usage": "TUSM",
        "capacity": 120,
        "abbr": "TETBLG03",
      ],
    ]
  }

  private func parseDate(_ value: String) -> Date? {
    ISO8601DateFormatter().date(from: value)
  }
}

// MARK: - CancellingApolloURLSession

private final actor CancellingApolloURLSession: ApolloURLSession {
  func chunks(for _: URLRequest) throws -> (any Apollo.AsyncChunkSequence, URLResponse) {
    throw URLError(.cancelled)
  }
}
