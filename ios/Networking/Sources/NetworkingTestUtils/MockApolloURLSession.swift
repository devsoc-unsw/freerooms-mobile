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

public final actor MockApolloURLSession: ApolloURLSession {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func hasResponse(for graphQLQueryType: any GraphQLQuery.Type) -> Bool {
    nextResponses.keys.contains(_GraphQLQueryMetatypeWrapper(graphQLQueryType))
  }

  public func setResponse(_ response: URLResponse, data: Data, for graphQLQueryType: any GraphQLQuery.Type) {
    nextResponses[_GraphQLQueryMetatypeWrapper(graphQLQueryType)] = (data, response)
  }

  public func response(for graphQLQueryType: any GraphQLQuery.Type) -> (Data, URLResponse)? {
    nextResponses[_GraphQLQueryMetatypeWrapper(graphQLQueryType)]
  }

  public func chunks(for request: URLRequest) throws -> (any Apollo.AsyncChunkSequence, URLResponse) {
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
    let (data, response) = try _savedResponse(query: query, operationName: operationName)

    return (_AsyncSequenceOfOne(value: data), response)
  }

  // MARK: Private

  /// The set next response for each response type
  private var nextResponses: [_GraphQLQueryMetatypeWrapper: (Data, URLResponse)] = [:]

  private func _savedResponse(
    query: String,
    operationName: String?)
    throws -> (Data, URLResponse)
  {
    func getSavedResponse(for type: any GraphQLQuery.Type) -> (Data, URLResponse) {
      nextResponses[_GraphQLQueryMetatypeWrapper(type)]!
    }

    // Get all saved response types
    let savedResponseTypes = nextResponses.keys.map(\.value)

    // Check if we have a matching saved response
    for type in savedResponseTypes {
      // Use operationName if possible
      if let operationName {
        if type.operationName == operationName {
          return getSavedResponse(for: type)
        }
      }

      // Otherwise fallback on using query
      if
        let definition = type.operationDocument.definition,
        definition.queryDocument == query
      {
        return getSavedResponse(for: type)
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
