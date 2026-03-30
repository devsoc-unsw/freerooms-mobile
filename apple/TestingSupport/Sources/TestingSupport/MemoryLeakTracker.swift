//
//  MemoryLeakTracker.swift
//  TestingSupport
//
//  Created by Anh Nguyen on 31/1/2025.
//

import Testing

public struct MemoryLeakTracker<T: AnyObject> {
  weak var instance: T?
  var sourceLocation: SourceLocation

  public init(instance: T, sourceLocation: SourceLocation) {
    self.instance = instance
    self.sourceLocation = sourceLocation
  }

  public func verifyDeallocation() {
    #expect(instance == nil, "Expected \(instance!) to be deallocated", sourceLocation: sourceLocation)
  }
}
