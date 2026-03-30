//
//  MockJSONLoader.swift
//  Persistence
//
//  Created by Chris Wong on 30/6/2025.
//

import Persistence

struct MockJSONLoader<T: Decodable>: JSONLoader {
  private let decodedData: T?
  private let JSONLoaderError: JSONLoaderError?

  init(loads decodedData: T? = nil, throws JSONLoaderError: JSONLoaderError? = nil) {
    self.decodedData = decodedData
    self.JSONLoaderError = JSONLoaderError
  }

  public typealias Result = Swift.Result<T, JSONLoaderError>

  public func load(from _: String) -> Result {
    if JSONLoaderError != nil {
      return .failure(JSONLoaderError!)
    }

    return .success(decodedData!)
  }
}
