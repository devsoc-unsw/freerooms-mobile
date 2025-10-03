//
//  NetworkCodableLoader.swift
//  Networking
//
//  Created by Anh Nguyen on 7/4/2025.
//

import Foundation

// MARK: - CodableLoader

public protocol CodableLoader {
  associatedtype Generic: Codable

  func fetch() async -> Swift.Result<Generic, Swift.Error>
}

// MARK: - NetworkCodableLoader

public class NetworkCodableLoader<T: Codable>: CodableLoader {

  // MARK: Lifecycle

  public init(client: HTTPClient, url: URL) {
    self.client = client
    self.url = url
  }

  nonisolated deinit { }

  // MARK: Public

  public enum Error: Swift.Error {
    case connectivity, invalidData
  }

  public typealias Result = Swift.Result<T, Swift.Error>

  public func fetch() async -> Result {
    switch await client.get(from: url) {
    case .success((let data, let response)):
      map(data, from: response)
    case .failure:
      .failure(Error.connectivity)
    }
  }

  // MARK: Private

  private static var okStatusCode: Int {
    200
  }

  private var client: HTTPClient
  private var url: URL

  private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    guard
      response.statusCode == NetworkCodableLoader.okStatusCode, let decodedData = try? JSONDecoder().decode(
        T.self,
        from: data)
    else {
      return .failure(Error.invalidData)
    }

    return .success(decodedData)
  }
}
