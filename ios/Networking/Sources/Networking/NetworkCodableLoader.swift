//
//  NetworkCodableLoader.swift
//  Networking
//
//  Created by Anh Nguyen on 7/4/2025.
//

public import Foundation

// MARK: - CodableLoader

public protocol CodableLoader {
  associatedtype Generic: Codable

  func fetch() async -> Swift.Result<Generic, any Swift.Error>
}

// MARK: - StatusCode

public enum StatusCode: Int {
  case ok = 200
}

// MARK: - NetworkCodableLoader

public final class NetworkCodableLoader<T: Codable & Sendable>: CodableLoader {

  // MARK: Lifecycle

  public init(client: any HTTPClient, url: URL) {
    self.client = client
    self.url = url
  }

  nonisolated deinit { }

  // MARK: Public

  public enum Error: Swift.Error {
    case connectivity, invalidData
  }

  public typealias Result = Swift.Result<T, any Swift.Error>

  public func fetch() async -> Result {
    switch await client.get(from: url) {
    case .success((let data, let response)):
      await Self.map(data, from: response)
    case .failure:
      .failure(Error.connectivity)
    }
  }

  // MARK: Private

  private let client: any HTTPClient
  private let url: URL

  @concurrent
  private static func map(_ data: Data, from response: HTTPURLResponse) async -> Result {
    guard
      response.statusCode == StatusCode.ok.rawValue, let decodedData = try? JSONDecoder().decode(
        T.self,
        from: data)
    else {
      return .failure(Error.invalidData)
    }

    return .success(decodedData)
  }
}
