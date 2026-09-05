//
//  FileBackedCodableTests.swift
//  Networking
//
//  Created by Matthew Yuen on 19/6/2026.
//

#if canImport(Darwin)
import Foundation
import Networking
import Testing

@Suite
nonisolated struct FileBackedCodableTests {

  // MARK: Lifecycle

  init() {
    let fileManager = FileManager.default
    let temporaryDirectory = fileManager.temporaryDirectory

    let concurrentQueue = DispatchQueue.global(qos: .utility)
    let operationQueue = OperationQueue()
    operationQueue.underlyingQueue = concurrentQueue

    self.fileManager = fileManager
    self.temporaryDirectory = temporaryDirectory
    self.concurrentQueue = concurrentQueue
    self.operationQueue = operationQueue
  }

  // MARK: Internal

  struct SimpleCodable: Codable, Equatable, Hashable {
    var foo: String
    var bar: Int
    var baz: Bool

    static let example = SimpleCodable(foo: "bar", bar: 42, baz: true)
  }

  let temporaryDirectory: URL
  let fileManager: FileManager
  let concurrentQueue: DispatchQueue
  let operationQueue: OperationQueue

  func withTemporaryFile<R: ~Copyable>(
    operation: (_ fileURL: URL) async throws -> sending R)
    async throws -> sending R
  {
    let tmpFileName = UUID().uuidString
    let fileURL = temporaryDirectory.appendingPathComponent(tmpFileName)

    func cleanup() throws {
      // Make sure we still delete the file, if it exists
      if fileManager.fileExists(atPath: fileURL.path) {
        try fileManager.removeItem(at: fileURL)
      }
    }

    let result: R
    do {
      result = try await operation(fileURL)
    } catch {
      try cleanup()
      // Rethrow the error
      throw error
    }

    try cleanup()
    return result
  }

  func coordinatedDelete(at fileURL: URL) async throws {
    nonisolated(unsafe) let fileManager = fileManager
    let coordinator = NSFileCoordinator()
    let intent = NSFileAccessIntent.writingIntent(with: fileURL, options: .forDeleting)
    return try await withCheckedThrowingContinuation { continuation in
      coordinator.coordinate(with: [intent], queue: operationQueue) { error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        do {
          try fileManager.removeItem(at: fileURL)
        } catch {
          continuation.resume(throwing: error)
          return
        }

        continuation.resume()
      }
    }
  }

  func coordinatedMove(from sourceURL: URL, to destinationURL: URL) async throws {
    nonisolated(unsafe) let fileManager = fileManager
    nonisolated(unsafe) let coordinator = NSFileCoordinator()

    let intents: [NSFileAccessIntent] = [
      .writingIntent(with: sourceURL, options: .forMoving),
      .writingIntent(with: destinationURL, options: .forMoving),
    ]

    return try await withCheckedThrowingContinuation { continuation in
      coordinator.coordinate(with: intents, queue: operationQueue) { error in
        if let error {
          continuation.resume(throwing: error)
        }

        do {
          coordinator.item(at: sourceURL, willMoveTo: destinationURL)
          try fileManager.moveItem(at: sourceURL, to: destinationURL)
          coordinator.item(at: sourceURL, didMoveTo: destinationURL)
        } catch {
          continuation.resume(throwing: error)
        }

        continuation.resume()
      }
    }
  }

  @Test("Nonexistent file has no value")
  func test_nonexistentFileHasNoValue() async throws {
    try await withTemporaryFile { fileURL in
      let wrapper = FileBackedCodable<SimpleCodable>(fileURL: fileURL)
      let value = try await wrapper.getValue()
      #expect(value == nil)
    }
  }

  @Test("Can round trip value using same wrapper")
  func test_canRoundTripValueUsingSameWrapper() async throws {
    try await withTemporaryFile { fileURL in
      let wrapper = FileBackedCodable<SimpleCodable>(fileURL: fileURL)
      let expectedValue = SimpleCodable.example
      try await wrapper.setValue(expectedValue)
      let returnedValue = try await wrapper.getValue()
      #expect(returnedValue == expectedValue)
    }
  }

  @Test("Can round trip value using different wrappers")
  func test_canRoundTripValueUsingDifferentWrappers() async throws {
    try await withTemporaryFile { fileURL in
      let firstWrapper = FileBackedCodable<SimpleCodable>(fileURL: fileURL)
      let secondWrapper = FileBackedCodable<SimpleCodable>(fileURL: fileURL)
      try await #expect(firstWrapper.getValue() == nil)
      try await #expect(secondWrapper.getValue() == nil)

      let expectedValue = SimpleCodable.example
      try await firstWrapper.setValue(expectedValue)
      let returnedValue = try await secondWrapper.getValue()
      #expect(returnedValue == expectedValue)
    }
  }

  @Test("Delete file has no value")
  func test_deletedFileHasNoValue() async throws {
    try await withTemporaryFile { fileURL in
      let firstWrapper = FileBackedCodable<SimpleCodable>(fileURL: fileURL)
      let secondWrapper = FileBackedCodable<SimpleCodable>(fileURL: fileURL)
      try await #expect(firstWrapper.getValue() == nil)
      try await #expect(secondWrapper.getValue() == nil)

      let value = SimpleCodable.example
      try await firstWrapper.setValue(value)

      // Make sure the file exists before we try to delete it
      try #require(fileManager.fileExists(atPath: fileURL.path))
      try await coordinatedDelete(at: fileURL)
      try #require(!fileManager.fileExists(atPath: fileURL.path))

      try await #expect(firstWrapper.getValue() == nil)
      try await #expect(secondWrapper.getValue() == nil)
    }
  }

}

#endif // canImport(Darwin)
