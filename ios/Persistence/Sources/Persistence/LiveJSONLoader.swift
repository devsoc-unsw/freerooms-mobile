//
//  JSONLoader.swift
//  Persistence
//
//  Created by Chris Wong on 22/6/2025.
//

import Buildings

// MARK: - LiveJSONLoaderError

public enum LiveJSONLoaderError: Error {
  case fileNotFound, malformedJSON
}

// MARK: - JSONLoader

public protocol JSONLoader {
  associatedtype T: Decodable
  func load(from file: String) -> Result<T, LiveJSONLoaderError> where T: Decodable
}

// MARK: - LiveJSONLoader

public struct LiveJSONLoader<T: Decodable>: JSONLoader {

  init(decodes fileName: String, with fileLoader: FileLoader = LiveFileLoader()) {
    self.fileName = fileName
    liveFileLoader = fileLoader
  }

  private let fileName: String
  private let liveFileLoader: FileLoader

  public typealias Result = Swift.Result<T, LiveJSONLoaderError>

  public func load(from _: String) -> Result {
    .failure(.fileNotFound)
  }

}
