//
//  FileLoader.swift
//  Persistence
//
//  Created by Chris Wong on 22/6/2025.
//

import Foundation

// MARK: - FileLoaderError

public enum FileLoaderError: Error {
  case fileNotFound
}

// MARK: - FileLoader

public protocol FileLoader {
  func loadFile(at path: String) throws -> Data
}

// MARK: - LiveFileLoader

struct LiveFileLoader: FileLoader {
  func loadFile(at path: String) throws -> Data {
    try Data(contentsOf: URL(fileURLWithPath: path))
  }
}
