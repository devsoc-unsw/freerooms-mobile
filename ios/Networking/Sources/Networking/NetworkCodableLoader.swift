//
//  NetworkCodableLoader.swift
//  Networking
//
//  Created by Anh Nguyen on 7/4/2025.
//

import Foundation
import TypeUtils

// MARK: - CodableLoader

public protocol CodableLoader: Sendable {
  associatedtype Generic: Codable

  func fetch() async -> Swift.Result<Generic, NetworkCodableError>
}

// MARK: - StatusCode

public enum StatusCode: Int {
  case ok = 200
}

// MARK: - NetworkCodableError

nonisolated
public struct NetworkCodableError: NetworkRequestError {

  // MARK: Lifecycle

  private init(reason: Reason, url: URL, networkError: (any Error)? = nil, httpResponse: HTTPURLResponse? = nil) {
    self.reason = reason
    self.url = url
    self.networkError = networkError
    self.httpResponse = httpResponse
  }

  // MARK: Public

  @AddCaseKind
  public enum Reason: Sendable {
    case clientError(HTTPClientError)
    case decodingError(any Error)
    case badResponse
  }

  public var reason: Reason
  public var url: URL
  public var networkError: (any Error)?
  public var httpResponse: HTTPURLResponse?

  public var errorDescription: String {
    switch reason {
    case .clientError:
      "HTTP client error"
    case .decodingError:
      "Server provided invalid data"
    case .badResponse:
      "Response was not ok"
    }
  }

  public static func clientError(_ error: HTTPClientError) -> Self {
    NetworkCodableError(
      reason: .clientError(error),
      url: error.url)
  }

  public static func decodingError(_ error: any Error, url: URL, response: HTTPURLResponse) -> Self {
    NetworkCodableError(
      reason: .decodingError(error),
      url: url,
      httpResponse: response)
  }

  public static func badResponse(url: URL, response: HTTPURLResponse) -> Self {
    NetworkCodableError(
      reason: .badResponse,
      url: url,
      httpResponse: response)
  }

}

// MARK: - NetworkCodableError.Reason + Equatable

extension NetworkCodableError.Reason: Equatable {

  public static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.clientError(let lhs), .clientError(let rhs)):
      lhs == rhs
    case (.decodingError(let lhs), .decodingError(let rhs)):
      lhs.isSimilar(to: rhs)
    case (.badResponse, .badResponse):
      true
    default:
      false
    }
  }

}

// MARK: - NetworkCodableLoader

/// Can be shared safely between decoders, JSONDecoder is sendable
private nonisolated let _networkCodableLoaderSharedDecoder = JSONDecoder()

// MARK: - NetworkCodableLoader

public final class NetworkCodableLoader<T: Codable>: CodableLoader {

  // MARK: Lifecycle

  public init(client: HTTPClient, url: URL) {
    self.client = client
    self.url = url
  }

  nonisolated deinit { }

  // MARK: Public

  public typealias Result = Swift.Result<T, NetworkCodableError>

  public func fetch() async -> Result {
    switch await client.get(from: url) {
    case .success((let data, let response)):
      guard response.statusCode == StatusCode.ok.rawValue else {
        return .failure(NetworkCodableError.badResponse(url: url, response: response))
      }
      return await map(data, httpResponse: response)

    case .failure(let error):
      return .failure(NetworkCodableError.clientError(error))
    }
  }

  // MARK: Private

  private let client: HTTPClient
  private let url: URL

  @concurrent
  private func map(_ data: Data, httpResponse: HTTPURLResponse) async -> Result {
    do {
      let decodedData = try _networkCodableLoaderSharedDecoder.decode(T.self, from: data)
      return .success(decodedData)
    } catch {
      return .failure(NetworkCodableError.decodingError(error, url: url, response: httpResponse))
    }
  }
}
