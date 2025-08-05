//
//  MockFileLoader.swift
//  Persistence
//
//  Created by Chris Wong on 22/6/2025.
//

import Foundation
import Persistence

struct MockFileLoader: FileLoader {

  private let contents: String
  private let fileLoaderError: FileLoaderError?

  init(loads contents: String = "", throws fileLoaderError: FileLoaderError? = nil) {
    self.contents = contents
    self.fileLoaderError = fileLoaderError
  }

  func load(at _: String) throws -> Data {
    if fileLoaderError != nil {
      throw fileLoaderError!
    }

    return contents.data(using: .utf8)!
  }
}
