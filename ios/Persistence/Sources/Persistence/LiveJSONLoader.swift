//
//  LiveJSONLoader.swift
//  Persistence
//
//  Created by Chris Wong on 22/6/2025.
//

import Foundation

// MARK: - JSONLoaderError

public enum JSONLoaderError: Error {
  case fileNotFound, malformedJSON
}

// MARK: - JSONLoader

public protocol JSONLoader<T> {
  associatedtype T: Decodable & Sendable
  func load(from file: String) async -> Result<T, JSONLoaderError>
}

// MARK: - LiveJSONLoader

public struct LiveJSONLoader<T: Decodable & Sendable>: JSONLoader {

  // MARK: Lifecycle

  public init(using fileLoader: FileLoader = LiveFileLoader()) {
    self.fileLoader = fileLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<T, JSONLoaderError>

  @concurrent
  public func load(from fileName: String) async -> Result {
    guard let data = try? await fileLoader.load(at: fileName) else {
      return .failure(.fileNotFound)
    }

    if let decodedData = try? JSONDecoder().decode(T.self, from: data) {
      return .success(decodedData)
    } else {
      return .failure(.malformedJSON)
    }
  }

  // MARK: Private

  private let fileLoader: FileLoader

}
