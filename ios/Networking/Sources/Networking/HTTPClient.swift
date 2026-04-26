//
//  HTTPClient.swift
//  Networking
//
//  Created by Anh Nguyen on 31/1/2025.
//

import Foundation
import VISOR

// MARK: - HTTPClient
public typealias HTTPClientResult = Swift.Result<(Data, HTTPURLResponse), Error>

// MARK: - HTTPClient

@Spyable
public protocol HTTPClient {
  func get(from url: URL) async -> HTTPClientResult
}

// MARK: - HTTPClientError

public enum HTTPClientError: Error {
  case networkFailure
  case invalidHTTPResponse
}
