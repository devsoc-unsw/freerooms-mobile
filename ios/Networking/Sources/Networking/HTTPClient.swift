//
//  HTTPClient.swift
//  Networking
//
//  Created by Anh Nguyen on 31/1/2025.
//

import Errors
import Foundation
import TypeUtils
import VISOR

// MARK: - HTTPClient
public typealias HTTPClientResult = Swift.Result<(Data, HTTPURLResponse), HTTPClientError>

// MARK: - HTTPClient

@Spyable
public protocol HTTPClient {
  func get(from url: URL) async -> HTTPClientResult
}

// MARK: - HTTPClientError

nonisolated
public struct HTTPClientError: NetworkRequestError {

  // MARK: Lifecycle

  private init(reason: Reason, networkError: (any Error)? = nil, url: URL) {
    self.reason = reason
    self.networkError = networkError
    self.url = url
  }

  // MARK: Public

  @AddCaseKind
  public enum Reason: Sendable, Equatable {
    case networkFailure
    case invalidHTTPResponse
  }

  public var reason: Reason
  public var networkError: (any Error)?
  public var url: URL

  public var errorDescription: String {
    switch reason {
    case .networkFailure:
      "Failed to connect to the server"
    case .invalidHTTPResponse:
      "The server returned an invalid response"
    }
  }

  public static func invalidHTTPResponse(url: URL) -> Self {
    HTTPClientError(
      reason: .invalidHTTPResponse,
      url: url)
  }

  public static func networkFailure(url: URL, networkError: any Error) -> Self {
    HTTPClientError(
      reason: .networkFailure,
      networkError: networkError,
      url: url)
  }

}

// MARK: Equatable

extension HTTPClientError: Equatable {

  public static func ==(lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
    let reasonsEqual: Bool =
      switch (lhs.networkError, rhs.networkError) {
      case (.some(let lhs), .some(let rhs)):
        lhs.isSimilar(to: rhs)
      case (nil, nil):
        true
      default:
        false
      }

    return
      lhs.reason == rhs.reason &&
      reasonsEqual &&
      lhs.url == rhs.url
  }

}
