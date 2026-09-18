//
//  MockHTTPClient.swift
//  RoomsTests
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

public import Foundation
public import Networking
import os

// MARK: - MockHTTPClient

public final class MockHTTPClient: HTTPClient {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public var stubbedData: Data? {
    get { _state.withLock(\.stubbedData) }
    set { _state.withLock { $0.stubbedData = newValue } }
  }

  public var stubbedError: (any Error)? {
    get { _state.withLock(\.stubbedError) }
    set { _state.withLock { $0.stubbedError = newValue } }
  }

  public func stubSuccess(_ data: some Codable, for _: String) {
    stubbedData = try? JSONEncoder().encode(data)
  }

  public func stubFailure() {
    stubbedError = NSError(domain: "test", code: 0)
  }

  public func get(from url: URL) async -> HTTPClientResult {
    _state.withLock { state in
      if let error = state.stubbedError {
        return .failure(error)
      }

      if let data = state.stubbedData {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return .success((data, response))
      }

      return .failure(NSError(domain: "test", code: 0))
    }
  }

  // MARK: Private

  private struct _State {
    var stubbedData: Data?
    var stubbedError: (any Error)?
  }

  private let _state = OSAllocatedUnfairLock(initialState: _State())

}
