//
//  _DispatchQueueSerialExecutor.swift
//  swift-foundation-utils
//
//  Created by Matthew Yuen on 14/6/2026.
//

#if canImport(Darwin)
internal import Dispatch

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
final class _DispatchQueueSerialExecutor: SerialExecutor {

  // MARK: Lifecycle

  init(wrapping queue: DispatchQueue) {
    self.queue = queue
  }

  // MARK: Internal

  let queue: DispatchQueue

  func enqueue(_ job: UnownedJob) {
    let executor = asUnownedSerialExecutor()
    queue.async {
      job.runSynchronously(on: executor)
    }
  }

  func asUnownedSerialExecutor() -> UnownedSerialExecutor {
    UnownedSerialExecutor(ordinary: self)
  }

}

#endif // canImport(Darwin)
