//
//  URLSessionHTTPClient.swift
//  Networking
//
//  Created by Anh Nguyen on 23/4/2025.
//

public import Foundation

// MARK: - URLSessionHTTPClient

@available(*, deprecated, message: "Use URLSession directly instead")
public struct URLSessionHTTPClient: HTTPClient, Sendable {

  // MARK: Lifecycle

  public init(session: any HTTPSession) {
    self.session = session
  }

  // MARK: Public

  public func get(from url: URL) async -> HTTPClientResult {
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

  private var session: any HTTPSession
}

// MARK: - HTTPSession

/// A protocol modeling the `data(from:)` method of `URLSession`
///
/// Conform custom mock classes to this `protocol` in order test server responses are correctly handled.
///
/// `URLSession` already conforms to this `protocol`.
public protocol HTTPSession: AnyObject, Sendable {
  func data(from url: URL) async throws -> (Data, URLResponse)
}

// MARK: - URLSession + HTTPSession

extension URLSession: HTTPSession { }
