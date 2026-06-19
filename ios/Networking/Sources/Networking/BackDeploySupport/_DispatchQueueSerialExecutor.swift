//
//  _DispatchQueueSerialExecutor.swift
//  swift-foundation-utils
//
//  Created by Matthew Yuen on 14/6/2026.
//

#if canImport(Darwin)
internal import Dispatch

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
internal final class _DispatchQueueSerialExecutor: SerialExecutor {
  internal let queue: DispatchQueue
  
  init(wrapping queue: DispatchQueue) {
    self.queue = queue
  }
  
  func enqueue(_ job: UnownedJob) {
    let executor = self.asUnownedSerialExecutor()
    queue.async {
      job.runSynchronously(on: executor)
    }
  }
  
  func asUnownedSerialExecutor() -> UnownedSerialExecutor {
    UnownedSerialExecutor(ordinary: self)
  }
  
}

#endif // canImport(Darwin)
