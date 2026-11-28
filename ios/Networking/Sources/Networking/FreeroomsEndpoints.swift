//
//  FreeroomsEndpoint.swift
//  Networking
//
//  Created by Matthew Yuen on 28/11/2026.
//

public import Foundation

/// A collection of endpoints for **Freerooms** services
public struct FreeroomsEndpoints: Sendable {
  
  /// The `URL` to the Hasuragres database
  public let hasuragres: URL
  
  /// The `URL` to the `api` endpoint of the backend server
  public let backend: URL
  
  public init(hasuragres: URL, backend: URL) {
    self.hasuragres = hasuragres
    self.backend = backend
  }
  
  #warning("TODO: Replace with fetching .well-known info when available")
  
  /// The current **production** endpoints
  public static let production = FreeroomsEndpoints(
    hasuragres: URL(string: "https://graphql.devsoc.app/v1/graphql")!,
    backend: URL(string: "https://freerooms.devsoc.app/api")!)
}
