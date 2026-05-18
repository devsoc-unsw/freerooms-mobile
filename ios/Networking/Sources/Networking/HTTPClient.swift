//
//  HTTPClient.swift
//  Networking
//
//  Created by Anh Nguyen on 31/1/2025.
//

import Foundation
import VISOR
import Errors

// MARK: - HTTPClient
public typealias HTTPClientResult = Swift.Result<(Data, HTTPURLResponse), HTTPClientError>

// MARK: - HTTPClient

@Spyable
public protocol HTTPClient {
  func get(from url: URL) async -> HTTPClientResult
}

// MARK: - HTTPClientError

nonisolated
public struct HTTPClientError: FreeroomsError {
  
  public enum Reason: Sendable {
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
