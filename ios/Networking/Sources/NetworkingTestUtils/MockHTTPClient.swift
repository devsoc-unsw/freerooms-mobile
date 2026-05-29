//
//  MockHTTPClient.swift
//  RoomsTests
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

import Foundation
import Networking

// MARK: - MockHTTPClient

public class MockHTTPClient: HTTPClient {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public static let defaultError = HTTPClientError.invalidHTTPResponse(url: URL(string: "https://example.com")!)

  public func stubSuccess(_ data: some Codable, for _: String) {
    stubbedData = try? JSONEncoder().encode(data)
  }

  public func stubFailure() {
    stubbedError = Self.defaultError
  }

  public func get(from url: URL) async -> HTTPClientResult {
    if let error = stubbedError {
      return .failure(error)
    }

    if let data = stubbedData {
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return .success((data, response))
    }

    return .failure(Self.defaultError)
  }

  // MARK: Private

  private var stubbedData: Data?
  private var stubbedError: HTTPClientError?
}
