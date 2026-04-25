//
//  HTTPClientSpy.swift
//  Networking
//
//  Created by Yanlin Li  on 26/4/2026.
//

import Foundation
import Networking

// MARK: - HTTPClientSpy

final class HTTPClientSpy: HTTPClient {
  var requestedURLs: [URL] = []
  var result: Swift.Result<(Data, HTTPURLResponse), Error> = .failure(AnyError())

  func get(from url: URL) async -> Swift.Result<(Data, HTTPURLResponse), Error> {
    requestedURLs.append(url)
    return result
  }
}

// MARK: - AnyError

struct AnyError: Error { }
