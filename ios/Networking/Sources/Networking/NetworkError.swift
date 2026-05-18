//
//  NetworkError.swift
//  Networking
//
//  Created by Matthew Yuen on 18/5/2026.
//

import Foundation
import Errors

/// Errors caused or involving a network request
public protocol NetworkRequestError: FreeroomsError {
  /// The `URL` of the request
  var url: URL { get }
  /// The response, if applicable
  var httpResponse: HTTPURLResponse? { get }
  /// The underlying network error, if applicable
  var networkError: (any Error)? { get }
}

public extension NetworkRequestError {
  var httpResponse: HTTPURLResponse? { nil }
  var networkError: (any Error)? { nil }
}
