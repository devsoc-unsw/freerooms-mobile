//
//  HTTPClient.swift
//  Networking
//
//  Created by Anh Nguyen on 31/1/2025.
//

import Foundation
import VISOR
import Errors
import TypeUtils

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
  
  public init(reason: Reason, networkError: (any Error)? = nil, url: URL) {
    self.reason = reason
    self.networkError = networkError
    self.url = url
  }
  
  public static func invalidHTTPResponse(url: URL) -> Self {
    HTTPClientError(
      reason: .invalidHTTPResponse,
      url: url
    )
  }
  
  public static func networkFailure(url: URL, networkError: any Error) -> Self {
    HTTPClientError(
      reason: .networkFailure,
      networkError: networkError,
      url: url
    )
  }
  
}

extension HTTPClientError: Equatable {
  
  public static func == (lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
    
    let reasonsEqual: Bool
    switch (lhs.networkError, rhs.networkError) {
    case let (.some(lhs), .some(rhs)):
      reasonsEqual = lhs.isSimilar(to: rhs)
    case (nil, nil):
      reasonsEqual = true
    default:
      reasonsEqual = false
    }
    
    return (
      lhs.reason == rhs.reason &&
      reasonsEqual &&
      lhs.url == rhs.url
    )
    
  }
  
}
