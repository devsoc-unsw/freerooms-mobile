internal import Dispatch
public import Foundation
import OSLog

#if canImport(UIKit)
/// Lifecycle management is required on iOS, or the app may be killed in the background
import UIKit
#endif

// MARK: - FileBackedCodable

/// A type that manages access to a file storing `Codable` data
public final actor FileBackedCodable<T: Codable & Sendable> {

  // MARK: Lifecycle

  /// Creates a new object managing a file
  ///
  /// - Parameters:
  ///   - fileURL: The `URL` to manage
  ///   - name: A name to given the object. Will be used in log messages.
  ///   - encoder: The encoder to use
  ///   - decoder: The decoder to use
  ///   - notificationCenter: The `NotificationCenter` to listen for app lifecycle notifications on iOS.
  ///   - fileManager: The `FileManager` to use
  public init(
    fileURL: URL,
    name: StaticString,
    encoder: JSONEncoder = JSONEncoder(), // could make use any TopLevelEncoder and any TopLevelDecoder instead
    decoder: JSONDecoder = JSONDecoder(),
    notificationCenter: NotificationCenter = .default, // needed to listen for background notifications on iOS
    fileManager: FileManager = .default)
  {
    // Shared object and presenter queue
    let serialQueue = DispatchSerialQueue(label: "FileBackedCodable", qos: .userInitiated)
    let operationQueue = OperationQueue()
    operationQueue.underlyingQueue = serialQueue

    // Presenter
    let presenter = _Presenter(
      _fileURL: fileURL,
      operationQueue: operationQueue)

    // init
    self.name = name
    self.serialQueue = serialQueue
    self.operationQueue = operationQueue
    self.notificationCenter = notificationCenter
    self.encoder = encoder
    self.decoder = decoder
    self.fileManager = fileManager
    _presenter = presenter
    _isPresenterRegistered = true
    _coordinatorOperationQueue = operationQueue

    logger = Logger(
      subsystem: "com.devsoc.FreeRooms.Networking",
      category: "FileBackedCodable (\(name))")

    // Presenter parent
    _presenter.parent = self

    // Handle app lifecycle on iOS
    #if canImport(UIKit)
    _registerForLifecycleNotifications()
    #endif

    // Register presenter
    // The flag is already set for it to be registered
    NSFileCoordinator.addFilePresenter(presenter)
    logger.trace("\(name): Presenter registered for url \(fileURL)")
  }

  deinit {
    #if canImport(UIKit)
    _unregisterForLifecycleNotifications()
    #endif
    // We can't safely check _isPresenterRegistered,
    // and removing a presenter more than once is always safe.
    NSFileCoordinator.removeFilePresenter(_presenter)
  }

  // MARK: Public

  /// The name of the object, to be used to differentiate instances
  public let name: StaticString
  public let encoder: JSONEncoder
  public let decoder: JSONDecoder

  /// The `NotificationCenter` observed for lifecycle events
  ///
  /// Used on `iOS` to prevent deadlocking the file
  public let notificationCenter: NotificationCenter

  public let fileManager: FileManager

  public nonisolated var unownedExecutor: UnownedSerialExecutor {
    // Part of the `Actor` protocol, allows the replacement of the actor's default executor
    serialQueue.asUnownedSerialExecutor()
  }

  public var currentFileURL: URL {
    _presenter._presentedItemURL
  }

  /// Allows the current saved version of the file to be checked
  public var cachedFileVersion: NSFileVersion? {
    switch _fileVersionState {
    case .updated(let version):
      version
    case .deleted, .none:
      nil
    }
  }

  /// Get the current value
  ///
  /// If the value has been updated elsewhere, the updated value will be fetched from the file system.
  /// Otherwise, the cached value will be used instead.
  public func getValue() async throws -> T? {
    // Check if the file exists, or if the cache is stale.
    // The cache is stale if the file was deleted, created or modified
    let isStale: Bool
    let url = currentFileURL
    // We get the current version of the file to check if we need to load it
    let currentFileVersion = NSFileVersion.currentVersionOfItem(at: url)
    switch _fileVersionState {
    case .updated(let fileVersion):
      isStale = (fileVersion != currentFileVersion)
    case .deleted:
      isStale = (currentFileVersion != nil)
    case nil:
      // Always load the file value if it hasn't been loaded yet
      isStale = true
    }

    let name = name

    // If the cache isn't stale, return the cached value
    // Prefer to use the cache, as file system access is expensive
    if !isStale {
      logger.trace("\(name): Returning cached value")
      return _cachedValue
    }

    logger.trace("\(name): Cached value is stale, loading from file")

    // Otherwise read the file
    return try await _getValue_getFromFile(url: url)
  }

  public func setValue(_ newValue: T?) async throws {
    let name = name
    let url = currentFileURL
    let intent: NSFileAccessIntent
    let isDeleting: Bool
    if newValue != nil {
      intent = .writingIntent(with: url)
      isDeleting = false
    } else {
      intent = .writingIntent(with: url, options: .forDeleting)
      isDeleting = true
    }

    logger.trace("\(name): Updating file")

    // Write the new version of the data
    nonisolated(unsafe) let fileManager = fileManager
    let newFileVersion: NSFileVersion? = try await _withCoordinatedAccess(for: intent) { [encoder] _ in
      // Check if we are deleting the file
      guard !isDeleting else {
        // Try to delete the file
        try fileManager.removeItem(at: intent.url)
        return nil
      }

      // Perform the write
      let data = try encoder.encode(newValue)
      try data.write(to: intent.url)

      // Get the new file version
      let newFileVersion = NSFileVersion.currentVersionOfItem(at: intent.url)
      guard let newFileVersion else {
        preconditionFailure(
          "File version should not be nil when file exists. Make sure the file exists before reaching this point")
      }
      return newFileVersion
    }

    logger.trace("\(name): Updated file successfully, updating cache")

    // Update the object cache
    _cachedValue = newValue
    if let newFileVersion {
      _fileVersionState = .updated(newFileVersion)
    } else {
      _fileVersionState = .deleted
    }
  }

  // MARK: Private

  private let logger: Logger

  /// While the presenter is non-Sendable,
  /// registering and unregistering the presenter is thread-safe.
  nonisolated(unsafe)
  private let _presenter: _Presenter

  /// The serial queue is used instead of the `actor`'s default executor,
  /// as we want to have an `OperationQueue` to pass to `NSFileCoordinator.coordinate`
  private nonisolated let serialQueue: DispatchSerialQueue
  private nonisolated let operationQueue: OperationQueue

  /// The `OperationQueue` for the coordinator to use
  ///
  /// This is intentionally not the same queue as the one used for `_presenter`
  private let _coordinatorOperationQueue: OperationQueue

  // MARK: Data

  private var _cachedValue: T?
  private var _fileVersionState: FileVersionState?

  // MARK: File Coordination

  /// Whether the presenter is currently registerd or not
  private var _isPresenterRegistered: Bool

  /// Fetch the data from the file system, and attempt to decode it
  private func _getValue_getFromFile(url: URL) async throws -> T? {
    /// The `FileManager` class is generally thread safe, but the `delegate` property is not
    nonisolated(unsafe) let fileManager = fileManager
    let name = name

    // Preform the coordinated read
    let intent = NSFileAccessIntent.readingIntent(with: url)

    let result: (data: Data?, fileVersionState: FileVersionState) = try await _withCoordinatedAccess(for: intent) { _ in
      // Check if the file exists
      guard fileManager.fileExists(atPath: url.path) else {
        return (nil, .deleted)
      }

      // Perform the read with coordinated access
      let data = try Data(contentsOf: intent.url)

      // Get the new file version for caching
      // This allows us to know when the file has been updated
      let newFileVersion = NSFileVersion.currentVersionOfItem(at: intent.url)
      guard let newFileVersion else {
        preconditionFailure(
          "File version should not be nil when file exists. Make sure the file exists before reaching this point")
      }
      return (data, .updated(newFileVersion))
    }

    logger.trace("\(name): Fetched data from \(url)")

    guard let data = result.data, result.fileVersionState != .deleted else {
      return nil
    }

    // Attempt to decode the data
    let newValue = try decoder.decode(T.self, from: data)
    // Update the cache and metadata
    _cachedValue = newValue
    _fileVersionState = result.fileVersionState

    // Return the found data
    return newValue
  }

  private func _withCoordinatedAccess<R>(
    returning _: R.Type = R.self,
    for intent: NSFileAccessIntent,
    operation: @escaping @Sendable (_ coordinator: NSFileCoordinator) throws -> sending R)
    async throws -> sending R
  {
    // Create a coordinator for the operation
    nonisolated(unsafe) let coordinator = NSFileCoordinator(filePresenter: _presenter)
    return try await withCheckedThrowingContinuation { continuation in
      coordinator.coordinate(with: [intent], queue: _coordinatorOperationQueue) { error in
        // Make sure there isn't an error
        // If an error is provided, the file isn't safe to read or modify
        if let error {
          continuation.resume(throwing: error)
          return
        }

        // Otherwise run the operation
        do {
          continuation.resume(returning: try operation(coordinator))
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }

  private func _registerPresenter() {
    guard !_isPresenterRegistered else { return }
    let name = name
    logger.trace("\(name): Registering file presenter")
    NSFileCoordinator.addFilePresenter(_presenter)
    _isPresenterRegistered = true
  }

  private func _unregisterPresenter() {
    guard _isPresenterRegistered else { return }
    let name = name
    logger.trace("\(name): Unregistering file presenter")
    NSFileCoordinator.removeFilePresenter(_presenter)
    _isPresenterRegistered = false
  }

  #if canImport(UIKit)
  private nonisolated func _registerForLifecycleNotifications() {
    notificationCenter.addObserver(
      self,
      selector: #selector(_handleAppDidEnterBackground(_:)),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil)
    notificationCenter.addObserver(
      self,
      selector: #selector(_handleAppWillEnterForeground(_:)),
      name: UIApplication.willEnterForegroundNotification,
      object: nil)
  }

  private nonisolated func _unregisterForLifecycleNotifications() {
    notificationCenter.removeObserver(
      self,
      name: UIApplication.didEnterBackgroundNotification,
      object: nil)
    notificationCenter.removeObserver(
      self,
      name: UIApplication.willEnterForegroundNotification,
      object: nil)
  }

  @objc // Likely @MainActor
  private nonisolated func _handleAppDidEnterBackground(_: Notification) {
    Task { await self._unregisterPresenter() }
  }

  @objc // Likely @MainActor
  private nonisolated func _handleAppWillEnterForeground(_: Notification) {
    Task { await self._registerPresenter() }
  }
  #endif // canImport(UIKit)

}

extension FileBackedCodable {

  enum FileVersionState: Equatable {
    case updated(NSFileVersion)
    case deleted
  }

  final class _Presenter: NSObject, NSFilePresenter {

    // MARK: Lifecycle

    init(
      _fileURL fileURL: URL,
      operationQueue: OperationQueue)
    {
      // init
      self.operationQueue = operationQueue
      _presentedItemURL = fileURL
    }

    // We intentially do not handle file moves, as it would overcomplicate
    // the implementation, and make accessing the current URL much slower

    // MARK: Internal

    weak var parent: FileBackedCodable?

    let operationQueue: OperationQueue

    var _presentedItemURL: URL

    var presentedItemURL: URL? {
      _presentedItemURL
    }

    var presentedItemOperationQueue: OperationQueue {
      operationQueue
    }

  }

}
