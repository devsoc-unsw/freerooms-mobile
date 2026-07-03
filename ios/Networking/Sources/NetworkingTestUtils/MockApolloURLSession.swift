//
//  MockApolloClient.swift
//  Networking
//
//  Created by Matthew Yuen on 3/6/2026.
//

import Apollo
import ApolloAPI
import Foundation

// MARK: - MockApolloURLSession

/// Mock for `ApolloURLSession`
public final actor MockApolloURLSession: ApolloURLSession {

  // MARK: Lifecycle

  /// Creates a new mock session
  ///
  /// - Parameters:
  ///   - clearOnRequest: Whether to remove the response when a request is received
  public init(clearOnRequest: Bool = true) {
    self.clearOnRequest = clearOnRequest
  }

  // MARK: Public

  /// Whether to clear a saved response when a corresponding request is received.
  public let clearOnRequest: Bool

  /// Check if a `GraphQLQuery` type has a set response
  ///
  /// - Parameters:
  ///   - graphQLQueryType: The type to check
  ///
  /// - Returns:
  ///   `true` if the type has a corresponding response, otherwise `false`
  public func hasResponse(for graphQLQueryType: any GraphQLQuery.Type) -> Bool {
    nextResponses.keys.contains(_GraphQLQueryMetatypeWrapper(graphQLQueryType))
  }

  /// Sets the response for a particular query
  ///
  /// - Parameters:
  ///   - response: The response to return
  ///   - data: The response body
  ///   - graphQLQueryType: The query to set the response for
  public func setResponse(_ response: URLResponse, data: Data, for graphQLQueryType: any GraphQLQuery.Type) {
    nextResponses[_GraphQLQueryMetatypeWrapper(graphQLQueryType)] = (data, response)
  }

  /// Gets the current response for a query type
  ///
  /// - Parameters:
  ///   - graphQLQueryType: The query type to check
  ///
  /// - Returns:
  ///   The current body and response for the query type, or `nil` if no response is set.
  public func response(for graphQLQueryType: any GraphQLQuery.Type) -> (data: Data, response: URLResponse)? {
    nextResponses[_GraphQLQueryMetatypeWrapper(graphQLQueryType)]
  }

  /// Sets a handler for a specific response type
  public func setResponseHandler<T: GraphQLQuery>(
    for queryType: T.Type = T.self,
    handler: @Sendable @escaping (_ query: String, _ operationName: String?) async throws -> (data: Data, response: URLResponse))
  {
    // Set the handler for the query type
    responseHandlers[_GraphQLQueryMetatypeWrapper(queryType)] = handler
  }

  /// Removes the saved response for a query type
  ///
  /// - Parameters:
  ///   - graphQLQueryType: The query type
  public func removeResponse(for graphQLQueryType: any GraphQLQuery.Type) {
    nextResponses.removeValue(forKey: _GraphQLQueryMetatypeWrapper(graphQLQueryType))
  }

  public func chunks(for request: URLRequest) async throws -> (any Apollo.AsyncChunkSequence, URLResponse) {
    // Requests should be sent by the ApolloClient, should ideally never be null
    guard request.url != nil, let bodyData = request.httpBody else {
      throw Error.badRequest
    }

    // Get request data from the body
    guard
      let body = try JSONSerialization.jsonObject(with: bodyData) as? [String: Any],
      let query = body["query"] as? String
    else {
      throw Error.badRequest
    }
    let operationName = body["operationName"] as? String
    let _ = body["variables"] as? [String: Any]

    // Get saved response if it exists
    let (data, response) = try await _savedResponse(query: query, operationName: operationName)

    return (_AsyncSequenceOfOne(value: data), response)
  }

  // MARK: Private

  /// The set next response for each response type
  private var nextResponses: [_GraphQLQueryMetatypeWrapper: (Data, URLResponse)] = [:]
  private var responseHandlers: [_GraphQLQueryMetatypeWrapper: (String, String?) async throws -> (Data, URLResponse)] = [:]

  private func _savedResponse(
    query: String,
    operationName: String?)
    async throws -> (Data, URLResponse)
  {
    func getSavedResponse(for typeKey: _GraphQLQueryMetatypeWrapper) async throws -> (Data, URLResponse) {
      // Use a saved response first if it exists
      if let nextResponse = nextResponses[typeKey] {
        if clearOnRequest {
          nextResponses.removeValue(forKey: typeKey)
        }
        return nextResponse
      }

      // Otherwise use a response handler
      if let responseHandler = responseHandlers[typeKey] {
        return try await responseHandler(query, operationName)
      }

      preconditionFailure("unreachable, function assumes a response is set or a handler")
    }

    // Get all saved response types
    let savedResponseTypes = Set(nextResponses.keys)
      .union(responseHandlers.keys)

    // Check if we have a matching saved response
    for type in savedResponseTypes {
      // Use operationName if possible
      if let operationName {
        if type.value.operationName == operationName {
          return try await getSavedResponse(for: type)
        }
      }

      // Otherwise fallback on using query
      if
        let definition = type.value.operationDocument.definition,
        definition.queryDocument == query
      {
        return try await getSavedResponse(for: type)
      }
    }

    // If we reach this point, there is no saved response
    throw Error.noSetResponse
  }

}

// MARK: - _AsyncSequenceOfOne

nonisolated private struct _AsyncSequenceOfOne<Element: Sendable>: AsyncSequence, Sendable {

  // MARK: Lifecycle

  init(value: Element) {
    self.value = value
  }

  // MARK: Internal

  nonisolated struct AsyncIterator: AsyncIteratorProtocol {
    let value: Element
    var taken: Bool

    init(value: Element) {
      self.value = value
      taken = false
    }

    mutating func next() -> Element? {
      guard !taken else { return nil }
      taken = true
      return value
    }
  }

  let value: Element

  func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(value: value)
  }

}

// MARK: Apollo.AsyncChunkSequence

nonisolated extension _AsyncSequenceOfOne: Apollo.AsyncChunkSequence where Element == Data { }

// MARK: - _GraphQLQueryMetatypeWrapper

/// Needed because metatypes are not Sendable
nonisolated private struct _GraphQLQueryMetatypeWrapper: Hashable {
  let value: any GraphQLQuery.Type

  init(_ value: any GraphQLQuery.Type) {
    self.value = value
  }

  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.value == rhs.value
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(value))
  }

}

// MARK: - MockApolloURLSession.Error

extension MockApolloURLSession {

  enum Error: Swift.Error {
    case badRequest
    case noSetResponse
  }

}
