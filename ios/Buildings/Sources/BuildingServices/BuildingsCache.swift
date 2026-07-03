//
//  BuildingsCache.swift
//  Buildings
//
//  Created by Matthew Yuen on 11/6/2026.
//

import BuildingModels
import Dispatch
import Foundation
import Networking
import OSLog
import VISOR

// MARK: - BuildingsCache

public nonisolated protocol BuildingsCache: Actor, Sendable {
  func getBuildings() async throws -> [Building]?
  func setBuildings(_ buildings: [Building]?) async throws
  func clear() async throws
  var lastUpdated: Date? { get throws }
}

// MARK: - OnDiskBuildingsCache

/// Represents an on-disk buildings cache
///
/// > Warning:
/// > This object assumes that it is the only cache for the file at the url,
/// > do not create multiple instances of this object for the same url.
///
@available(*, deprecated, renamed: "FileBackedCodable", message: "Use FileBackedCodable instead")
public final actor OnDiskBuildingsCache {

  // MARK: Lifecycle

  public init(
    url: URL,
    decoder: JSONDecoder = JSONDecoder(),
    encoder: JSONEncoder = JSONEncoder())
  {
    self.url = url
    self.decoder = decoder
    self.encoder = encoder
  }

  // MARK: Public

  /// The shared buildings cache
  ///
  /// If the cache could not be created, an `Error` result is provided instead
  public static let shared = Result<OnDiskBuildingsCache, any Error> {
    let fm = FileManager.default

    // Does this fail?
    let cachesDirectory = try fm.url(
      for: .cachesDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false)
    let buildingsCacheURL = cachesDirectory.appending(path: "buildingsCache.json")
    logger.debug("Create buildings cache at: \(buildingsCacheURL.path)")

    return OnDiskBuildingsCache(url: buildingsCacheURL)
  }

  public nonisolated let url: URL
  public nonisolated let decoder: JSONDecoder
  public nonisolated let encoder: JSONEncoder

  // MARK: Internal

  static let logger = Logger(subsystem: "com.devsoc.Freerooms.BuildingServices", category: "OnDiskBuildingsCache")

  var _buildings: [Building]?
  var _lastUpdated: Date?

  var logger: Logger { Self.logger }

  func _getBuildings() throws -> [Building]? {
    // Check if we have already retrieved data
    if let buildings = _buildings {
      return buildings
    }

    // Check if the file exists
    let fm = FileManager.default
    guard fm.fileExists(atPath: url.path()) else { return nil }

    // Try to decode the data
    let data = try Data(contentsOf: url)
    let buildings = try decoder.decode([Building].self, from: data)
    if let version = NSFileVersion.currentVersionOfItem(at: url) {
      if let modificationDate = version.modificationDate {
        _lastUpdated = modificationDate
      } else {
        assertionFailure("Must not use a version of a deleted file")
      }
    } else {
      let url = url
      logger.warning("Unable to get file version, even though file exists (url: \(url))")
      _lastUpdated = nil
    }

    // Set the new cache info
    return buildings
  }

  func _setBuildings(_ buildings: [Building]?) throws {
    // If we are setting no buildings, clear the cache
    guard let buildings else {
      try _clearBuildings()
      return
    }

    let data = try encoder.encode(buildings)
    try data.write(to: url)
  }

  func _clearBuildings() throws {
    _buildings = nil
    _lastUpdated = nil
    try FileManager.default.removeItem(at: url)
  }

}

// MARK: BuildingsCache

@available(*, deprecated)
extension OnDiskBuildingsCache: BuildingsCache {

  public var lastUpdated: Date? {
    get throws {
      if _lastUpdated == nil {
        _ = try _getBuildings()
      }
      return _lastUpdated
    }
  }

  public func getBuildings() throws -> [Building]? {
    guard let buildings = try _getBuildings() else { return nil }
    return buildings
  }

  public func setBuildings(_ buildings: [Building]?) throws {
    try _setBuildings(buildings)
  }

  public func clear() throws {
    try _setBuildings(nil)
  }

}

// MARK: - FileBackedCodable + BuildingsCache

extension FileBackedCodable: BuildingsCache where T == [Building] {

  public static let sharedBuildingsCache = Result<FileBackedCodable, any Error> {
    let fm = FileManager.default

    // Does this fail?
    let cachesDirectory = try fm.url(
      for: .cachesDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false)
    let buildingsCacheURL = cachesDirectory.appending(path: "buildingsCache.json")
//    logger.debug("Create buildings cache at: \(buildingsCacheURL.path)")

    return FileBackedCodable(fileURL: buildingsCacheURL)
  }

  public var lastUpdated: Date? {
    get throws {
      guard let version = cachedFileVersion else { return nil }
      return version.modificationDate
    }
  }

  public func getBuildings() async throws -> [Building]? {
    try await getValue()
  }

  public func setBuildings(_ buildings: [Building]?) async throws {
    try await setValue(buildings)
  }

  public func clear() async throws {
    try await setValue(nil)
  }

}
