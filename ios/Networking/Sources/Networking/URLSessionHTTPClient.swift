//
//  URLSessionHTTPClient.swift
//  Networking
//
//  Created by Anh Nguyen on 23/4/2025.
//

import Foundation

// MARK: - URLSessionHTTPClient

@available(macOS 12.0, *)
public struct URLSessionHTTPClient: HTTPClient {

  // MARK: Lifecycle

  public init(session: HTTPSession) {
    self.session = session
  }

  // MARK: Public

  public func get(from url: URL) async -> HTTPClient.Result {
    do {
      let (data, urlResponse) = try await session.data(from: url)
      guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
        return .failure(HTTPClientError.invalidHTTPResponse)
      }
      return .success((data, httpUrlResponse))
    } catch {
      return .failure(HTTPClientError.networkFailure)
    }
  }

  // MARK: Private

  private var session: HTTPSession
}

// MARK: - HTTPSession

public protocol HTTPSession {
  func data(from url: URL) async throws -> (Data, URLResponse)
}

// MARK: - URLSession + HTTPSession

@available(macOS 12.0, *)
extension URLSession: HTTPSession { }
