//
//  JSONLoader.swift
//  Persistence
//
//  Created by Chris Wong on 22/6/2025.
//

import Foundation

// MARK: - LiveJSONLoaderError

public enum LiveJSONLoaderError: Error {
  case fileNotFound, malformedJSON
}

// MARK: - JSONLoader

public protocol JSONLoader {
  associatedtype T: Decodable
  func load(from file: String) -> Result<T, LiveJSONLoaderError>
}

// MARK: - LiveJSONLoader

public struct LiveJSONLoader<T: Decodable>: JSONLoader {

  // MARK: Lifecycle

  init(using fileLoader: FileLoader = LiveFileLoader()) {
    self.fileLoader = fileLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<T, LiveJSONLoaderError>

  public func load(from fileName: String) -> Result {
    guard let data = try? fileLoader.loadFile(at: fileName) else {
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
