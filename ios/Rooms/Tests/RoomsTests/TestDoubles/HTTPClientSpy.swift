//
//  HTTPClientSpy.swift
//  Networking
//
//  Created by Yanlin Li  on 26/4/2026.
//

import Foundation
import Networking


public final class HTTPClientSpy: HTTPClient {
  
  public init() { }
  
  public var requestedURLs: [URL] = []
  public var result: Swift.Result<(Data, HTTPURLResponse), Error> = .failure(AnyError())
  
  public func get(from url: URL) async -> Swift.Result<(Data, HTTPURLResponse), Error> {
    requestedURLs.append(url)
    return result
  }
}

private struct AnyError: Error {}
