#if canImport(Darwin)
internal import Dispatch
public import Foundation

#if canImport(UIKit)
import UIKit
#endif

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
public final actor FileBackedCodable<T: Codable & Sendable> {
  
  // While the presenter is non-Sendable,
  // registering and unregistering the presenter is thread-safe.
  nonisolated(unsafe)
  private let _presenter: _Presenter
  
  private nonisolated let serialExecutor: _DispatchQueueSerialExecutor
  private nonisolated let operationQueue: OperationQueue
  
  public nonisolated var unownedExecutor: UnownedSerialExecutor {
    serialExecutor.asUnownedSerialExecutor()
  }

  public let encoder: JSONEncoder
  public let decoder: JSONDecoder
  
  /// The `NotificationCenter` observed for lifecycle events
  ///
  /// Used on `iOS` to prevent deadlocking the file
  public let notificationCenter: NotificationCenter
  
  public let fileManager: FileManager
  
  /// The `OperationQueue` for the coordinator to use
  ///
  /// This is intentionally not the same queue as the one used for `_presenter`
  private let _coordinatorOperationQueue: OperationQueue
  
  public init(
    fileURL: URL,
    encoder: JSONEncoder = JSONEncoder(),
    decoder: JSONDecoder = JSONDecoder(),
    notificationCenter: NotificationCenter = .default,
    fileManager: FileManager = .default
  ) {
    
    // Shared object and presenter queue
    let serialQueue = DispatchQueue(label: "FileBackedCodable", qos: .userInitiated)
    let operationQueue = OperationQueue()
    operationQueue.underlyingQueue = serialQueue
    
    // Presenter
    let presenter = _Presenter(
      _fileURL: fileURL,
      operationQueue: operationQueue)
    
    // init
    self.serialExecutor             = _DispatchQueueSerialExecutor(wrapping: serialQueue)
    self.operationQueue             = operationQueue
    self.notificationCenter         = notificationCenter
    self.encoder                    = encoder
    self.decoder                    = decoder
    self.fileManager                = fileManager
    self._presenter                 = presenter
    self._isPresenterRegistered     = true
    self._coordinatorOperationQueue = operationQueue
    
    // Presenter parent
    self._presenter.parent = self
    
    // Handle app lifecycle on iOS
#if canImport(UIKit)
    _registerForLifecycleNotifications()
#endif
    
    // Register presenter
    NSFileCoordinator.addFilePresenter(presenter)
  }
  

  deinit {
#if canImport(UIKit)
    _unregisterForLifecycleNotifications()
#endif
    // We can't safely check _isPresenterRegistered,
    // and removing a presenter more than once is always safe.
    NSFileCoordinator.removeFilePresenter(_presenter)
  }
  
  // MARK: Data
  
  private var _cachedValue: T?
  private var _fileVersionState: FileVersionState?
  
  public var currentFileURL: URL {
    _presenter._presentedItemURL
  }
  
  public var cachedFileVersion: NSFileVersion? {
    switch _fileVersionState {
    case .updated(let version):
      return version
    case .deleted, .none:
      return nil
    }
  }
  
  public func getValue() async throws -> T? {
    
    // Check if the file exists, or if the cache is stale.
    // The cache is stale if the file was deleted, created or modified
    let isStale: Bool
    let url = currentFileURL
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
    
    // If the cache isn't stale, return the cached value
    if !isStale {
      return _cachedValue
    }
    
    // Otherwise read the file
    return try await _getValue_getFromFile(url: url)
  }
  
  private func _getValue_getFromFile(url: URL) async throws -> T? {
    nonisolated(unsafe) let fileManager = self.fileManager
   
    // Preform the coordinated read
    let intent = NSFileAccessIntent.readingIntent(with: url)
    
    let result: (data: Data?, fileVersionState: FileVersionState) = try await _withCoordinatedAccess(for: intent) {
      
      // Check if the file exists
      guard fileManager.fileExists(atPath: url.path) else {
        return (nil, .deleted)
      }
      
      // Perform the read
      let data = try Data(contentsOf: intent.url)
      
      // Get the new file version for caching
      let newFileVersion = NSFileVersion.currentVersionOfItem(at: intent.url)
      guard let newFileVersion else {
        preconditionFailure(
          "File version should not be nil when file exists. Make sure the file exists before reaching this point")
      }
      return (data, .updated(newFileVersion))
    }
    
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
  
  public func setValue(_ newValue: T?) async throws {
    
    let url = currentFileURL
    let intent = NSFileAccessIntent.writingIntent(with: url)
    
    // Write the new version of the data
    let newFileVersion: NSFileVersion = try await _withCoordinatedAccess(for: intent) { [encoder] in
      
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
    
    // Update the object cache
    _cachedValue = newValue
    _fileVersionState = .updated(newFileVersion)
  }
  
  private func _withCoordinatedAccess<R>(
    returning _: R.Type = R.self,
    for intent: NSFileAccessIntent,
    operation: @escaping @Sendable () throws -> sending R
  ) async throws -> sending R {
    
    // Create a coordinator for the operation
    let coordinator = NSFileCoordinator(filePresenter: _presenter)
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
          continuation.resume(returning: try operation())
        } catch {
          continuation.resume(throwing: error)
        }
      }
    }
  }
  
  // MARK: File Coordination
  
  /// Whether the presenter is currently registerd or not
  private var _isPresenterRegistered: Bool
  
  private func _registerPresenter() {
    guard !_isPresenterRegistered else { return }
    NSFileCoordinator.addFilePresenter(_presenter)
    _isPresenterRegistered = true
  }
  
  private func _unregisterPresenter() {
    guard _isPresenterRegistered else { return }
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
  private nonisolated func _handleAppDidEnterBackground(_ notification: Notification) {
    Task { await self._unregisterPresenter() }
  }
  
  @objc // Likely @MainActor
  private nonisolated func _handleAppWillEnterForeground(_ notification: Notification) {
    Task { await self._registerPresenter() }
  }
#endif // canImport(UIKit)

}

@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
extension FileBackedCodable {
  
  enum FileVersionState: Equatable {
    case updated(NSFileVersion)
    case deleted
  }
  
  final class _Presenter: NSObject, NSFilePresenter {
    weak var parent: FileBackedCodable?
    
    let operationQueue: OperationQueue
    
    var _presentedItemURL: URL
    
    var presentedItemURL: URL? {
      _presentedItemURL
    }
    
    var presentedItemOperationQueue: OperationQueue {
      operationQueue
    }
    
    init(
      _fileURL fileURL: URL,
      operationQueue: OperationQueue
    ) {
      // init
      self.operationQueue   = operationQueue
      self._presentedItemURL = fileURL
    }
    
    // We intentially do not handle file moves, as it would overcomplicate
    // the implementation, and make accessing the current URL much slower
    
  }
  
}

#endif // canImport(Darwin)
