//
//  DevSoc.swift
//  Networking
//
//  Created by Matthew Yuen on 2/6/2026.
//

import Apollo
import ApolloSQLite
import DevSocAPI
import Foundation
import OSLog

// MARK: - DevSoc

/// A `namespace` for DevSoc
///
/// This `namespace` has members relating to the DevSoc **GraphQL** API.
nonisolated public /* namespace */ enum DevSoc {

  /// The **production** GraphQL endpoint
  ///
  /// ```swift
  /// URL(string: "https://graphql.devsoc.app/v1/graphql")
  /// ```
  public static let defaultLiveUrl = URL(string: "https://graphql.devsoc.app/v1/graphql")!

  /// Creates a live DevSoc `ApolloClient` for GraphQL requests.
  ///
  /// To create a live client to make network requests:
  /// ```swift
  /// let cacheLocation = try DevSoc.onDiskCacheLocation
  /// let cache   = try DevSoc.createOnDiskCache(at: cacheLocation)
  /// let store   = ApolloStore(cache: cache)
  /// let client  = try DevSoc.createLiveApolloClient(using: store)
  /// ```
  ///
  /// - Parameters:
  ///   - url: The url to send requests to. Defaults to the live production `URL`.
  ///   - store: The store for caching.
  ///   - urlSession: The session to use for requests. Defaults to `URLSession.shared` for real requests.
  ///
  /// - Returns:
  ///   The `ApolloClient` to make GraphQL requests to.
  public static func createLiveApolloClient(
    for url: URL = DevSoc.defaultLiveUrl,
    using store: ApolloStore,
    urlSession: any ApolloURLSession = URLSession.shared)
    throws -> ApolloClient
  {
    // Create the network transport
    // We don't need any interceptors as we don't need auth for these requests (yet?)
    let transport = RequestChainNetworkTransport(
      urlSession: urlSession,
      interceptorProvider: DefaultInterceptorProvider.shared,
      store: store,
      endpointURL: url)

    // Create the client
    return ApolloClient(
      networkTransport: transport,
      store: store)
  }

}

extension DevSoc {

  // MARK: Public

  /// Get the `URL` of the on-disk cache
  ///
  /// This getter doesn't check for the existence of the cache, it merely provides
  /// where it should be located.
  ///
  /// - Returns:
  ///   The cache location within the apps bundle.
  public static var onDiskCacheLocation: URL {
    get throws {
      let fm = FileManager.default

      // Find the caches directory on disk
      // For more information, see:
      // https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW28
      let cacheDirectory: URL
      do {
        cacheDirectory = try fm.url(
          for: .cachesDirectory,
          in: .userDomainMask,
          appropriateFor: nil,
          create: true)
      } catch let error {
        logger.error("Failed to get caches directory: \(error)")
        throw error
      }

      // Add the filename to the path
      logger.debug("Found cache directory: \(cacheDirectory.path)")
      let cacheURL = cacheDirectory.appending(path: "apollo-cache.sqlite")
      logger.debug("Cache URL: \(cacheURL.path)")

      return cacheURL
    }
  }

  /// Attempts to create the cache at the provided location
  ///
  /// - Parameters:
  ///   - url: The location to create the cache. Must be accessable by the application.
  ///
  /// - Returns:
  ///   The `NormalizedCache` for caching on-disk.
  public static func createOnDiskCache(at url: URL) throws -> some NormalizedCache {
    let database = try ApolloSQLiteDatabase(fileURL: url)
    return try SQLiteNormalizedCache(database: database)
  }

  // MARK: Internal

  static let logger = Logger(subsystem: "app.devsoc.Freerooms.Networking", category: "DevSoc")

}
