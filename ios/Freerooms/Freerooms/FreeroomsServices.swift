//
//  FreeroomsServices.swift
//  Freerooms
//
//  Created by Matthew Yuen on 28/11/2026.
//

import Networking
import Apollo
import Foundation
import BuildingServices
import RoomServices

/// A group of dependencies and services for `ViewModel`s
final class FreeroomsServices: Sendable {
  
  // Endpoints
  let endpoints: FreeroomsEndpoints
  
  // Networking
  let httpClient: any HTTPSession
  
  // Apollo
  let apolloStore: ApolloStore
  let apolloClient: ApolloClient
  
  // Loaders
  let buildingLoader: any BuildingLoader
  let roomStatusLoader: any RoomStatusLoader
  
  // Services
  let buildingService: any BuildingServiceProtocol
  
  init(
    endpoints: FreeroomsEndpoints,
    httpClient: any HTTPSession,
    apolloStore: ApolloStore,
    apolloClient: ApolloClient,
    buildingLoader: any BuildingLoader,
    roomStatusLoader: any RoomStatusLoader,
    buildingService: any BuildingServiceProtocol)
  {
    self.endpoints = endpoints
    self.httpClient = httpClient
    self.apolloStore = apolloStore
    self.apolloClient = apolloClient
    self.buildingLoader = buildingLoader
    self.roomStatusLoader = roomStatusLoader
    self.buildingService = buildingService
  }
  
  /// Create the default **live** service group
  ///
  /// > Important:
  /// > Do not call this multiple times, keep the service group after creation.
  static func makeDefault() -> FreeroomsServices {
    
    // Get the current production endpoints
    // TODO: Avoid hardcoding these endpoints
    let endpoints = FreeroomsEndpoints.production
    
    // Get the URLSession
    let httpSession = DevSoc.urlSession
    
    // Create the Apollo Store with cache
    let apolloStore = ApolloStore(cache: InMemoryNormalizedCache())
    
    // Create the Apollo Client using the store
    let apolloClient = DevSoc.createLiveApolloClient(
      for: endpoints.hasuragres,
      using: apolloStore,
      urlSession: httpSession)
    
    // Room Status Loader
    let roomStatusLoader = LiveRoomStatusLoader(
      session: httpSession,
      baseURL: endpoints.backend)
    
    // Building Loader
    let buildingLoader = LiveGraphQLBuildingLoader(
      client: apolloClient,
      session: httpSession,
      baseURL: endpoints.backend,
      roomStatusLoader: roomStatusLoader,
      buildingsCache: nil)
    
    // Building service
    let buildingService = BuildingService(
      buildingLoader: buildingLoader)
    
    return FreeroomsServices(
      endpoints: endpoints,
      httpClient: httpSession,
      apolloStore: apolloStore,
      apolloClient: apolloClient,
      buildingLoader: buildingLoader,
      roomStatusLoader: roomStatusLoader,
      buildingService: buildingService)
  }
  
}
