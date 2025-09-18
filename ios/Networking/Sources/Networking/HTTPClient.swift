//
//  HTTPClient.swift
//  Networking
//
//  Created by Anh Nguyen on 31/1/2025.
//

import Foundation

// MARK: - HTTPClient

public protocol HTTPClient: Sendable {
  typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

  func get(from url: URL) async -> Result
}

// MARK: - HTTPClientError

public enum HTTPClientError: Error {
  case networkFailure
  case invalidHTTPResponse
}
