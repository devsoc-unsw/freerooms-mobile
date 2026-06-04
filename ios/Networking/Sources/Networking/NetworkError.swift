//
//  NetworkError.swift
//  Networking
//
//  Created by Matthew Yuen on 18/5/2026.
//

import Errors
import Foundation

// MARK: - NetworkRequestError

/// Errors caused or involving a network request
public protocol NetworkRequestError: FreeroomsError {
  /// The `URL` of the request
  var url: URL { get }
  /// The response, if applicable
  var httpResponse: HTTPURLResponse? { get }
  /// The underlying network error, if applicable
  var networkError: (any Error)? { get }
}

extension NetworkRequestError {
  public var httpResponse: HTTPURLResponse? { nil }
  public var networkError: (any Error)? { nil }
}
