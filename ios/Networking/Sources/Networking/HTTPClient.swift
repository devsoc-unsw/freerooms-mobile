//
//  HTTPClient.swift
//  Networking
//
//  Created by Anh Nguyen on 31/1/2025.
//

public import Foundation
import VISOR
public import VISORTestDoubles

// MARK: - HTTPClient
public typealias HTTPClientResult = Swift.Result<(Data, HTTPURLResponse), any Error>

// MARK: - HTTPClient

@GenerateSpy(.sendable)
public protocol HTTPClient: Sendable {
  func get(from url: URL) async -> HTTPClientResult
}

// MARK: - HTTPClientError

public enum HTTPClientError: Error {
  case networkFailure
  case invalidHTTPResponse
}
