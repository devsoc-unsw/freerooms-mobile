//
//  TestUtils.swift
//  TestingSupport
//
//  Created by Chris Wong on 4/9/2025.
//

import Testing

public func expect<E: Error & Equatable>(_ res: Result<some Equatable, E>, toThrow expected: E) {
  switch res {
  case .failure(let error):
    #expect(error == expected)
  case .success(let response):
    Issue.record("Expected an error but got \(response)")
  }
}

public func expect<T: Equatable>(_ res: Result<T, some Error & Equatable>, toFetch expected: T) {
  switch res {
  case .success(let rooms):
    #expect(rooms == expected)
  case .failure(let error):
    Issue.record("Expected success but got \(error)")
  }
}
