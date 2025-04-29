//
//  URLSessionHTTPClient.swift
//  Networking
//
//  Created by Anh Nguyen on 23/4/2025.
//

import Foundation

public struct URLSessionHTTPClient: HTTPClient {
  public init() { }

  public func get(from _: URL) async -> HTTPClient.Result {
    fatalError("TODO: Implement")
  }
}
