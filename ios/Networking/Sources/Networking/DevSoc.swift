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

// TODO: Find a better name for this namespace and the generated package

/// A `namespace` for DevSoc
///
/// This `namespace` has members relating to the DevSoc **GraphQL** API.
public /* namespace */ enum DevSoc {

  /// The **production** GraphQL endpoint
  public static let liveUrl = URL(string: "https://graphql.csesoc.app/v1/graphql")!

  /// Creates a live DevSoc `ApolloClient` for GraphQL requests
  ///
  /// - Parameters:
  ///   - url: The url to send requests to. Defaults to the live production `URL`.
  ///   - store: The store for caching. By default
  ///
  /// - Returns:
  ///   The `ApolloClient` to make GraphQL requests to.
  public static func createLiveApolloClient(
    for url: URL = DevSoc.liveUrl,
    using store: ApolloStore,
    urlSession: URLSession = .shared)
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
  /// where it should be located
  ///
  /// - Returns:
  ///   The cache location within the apps bundle.
  public static var onDiskCacheLocation: URL {
    get throws {
      let fm = FileManager.default

      // Find the caches directory on disk
      // For more information, see:
      // https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW28
      let cacheDirectory = try fm.url(
        for: .cachesDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true)

      logger.debug("Found cache directory: \(cacheDirectory.path)")
      let cacheURL = cacheDirectory.appendingPathComponent("apollo-cache.sqlite")
      logger.debug("Cache URL: \(cacheURL.path)")

      return cacheURL
    }
  }

  public static func createOnDiskCache(at url: URL) throws -> some NormalizedCache {
    let database = try ApolloSQLiteDatabase(fileURL: url)
    return try SQLiteNormalizedCache(database: database)
  }

  // MARK: Internal

  static let logger = Logger(subsystem: "app.devsoc.Freerooms.Networking", category: "DevSoc")

}
