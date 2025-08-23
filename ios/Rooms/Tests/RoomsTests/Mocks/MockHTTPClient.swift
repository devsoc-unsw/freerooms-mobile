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

  // MARK: Public

  public func stubSuccess(_ data: some Codable, for _: String) {
    stubbedData = try? JSONEncoder().encode(data)
  }

  public func stubFailure() {
    stubbedError = NSError(domain: "test", code: 0)
  }

  public func get(from url: URL) async -> HTTPClient.Result {
    if let error = stubbedError {
      return .failure(error)
    }

    if let data = stubbedData {
      let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return .success((data, response))
    }

    return .failure(NSError(domain: "test", code: 0))
  }

  // MARK: Private

  private var stubbedData: Data?
  private var stubbedError: Error?
}
