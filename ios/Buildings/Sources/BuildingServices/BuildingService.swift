//
//  BuildingService.swift
//  Buildings
//
//  Created by Anh Nguyen on 22/4/2025.
//

public import BuildingModels
public import Foundation
public import Networking
import VISOR
public import VISORObservation
public import VISORTestDoubles
public import Apollo
import DevSocAPI

/// Provides information about `Building`s
@GenerateSpy(.sendable)
@GenerateStub(.sendable)
public protocol BuildingServiceProtocol: Sendable {
  
  /// An `ObservationSource` that produces updates on when the list of buildings changes
  ///
  /// `ObservationChannel` conforms to `AsyncSequence`, but `ViewModel`s can also bind
  /// to it to update UI.
  ///
  /// To potentially update this value, call ``fetchBuildings()``.
  @DefaultValue(ObservationSource<[Building]?>.constant(nil))
  var source: ObservationSource<[Building]?> { get }
  
  /// Fetches the latest status of buildings
  ///
  /// The result can be discarded, as the update can also be observed though ``channel``.
  /// When an error occurs, a `nil` update to `channel` will be published.
  @discardableResult
  func fetchBuildings() async throws -> [Building]
  
}

public final class BuildingService: BuildingServiceProtocol {
  private let channel = ObservationChannel<[Building]?>(nil)
  private let endpoints: FreeroomsEndpoints
  private let httpSession: any HTTPSession
  private let apolloClient: ApolloClient
  
  public init(
    endpoints: FreeroomsEndpoints,
    httpSession: any HTTPSession,
    apolloClient: ApolloClient)
  {
    self.endpoints = endpoints
    self.httpSession = httpSession
    self.apolloClient = apolloClient
  }
  
  public var source: ObservationSource<[Building]?> {
    channel.source
  }
  
  @discardableResult
  public func fetchBuildings() async throws -> [Building] {
    #warning("TODO: Reimplement building caching")
    
    // Refetch from the server if required
    let buildings = try await fetchBuildingsFromServer()
    channel.publish(buildings)
    return buildings
  }
  
  private func fetchBuildingsFromServer() async throws -> [Building] {
    
    // Fetch building information from GraphQL
    let query = AllBuildingsQuery()
    let graphQLBuildings: [DevSocAPI.AllBuildingsQuery.Data.Building]
    
    // Fetch building list
    do {
      let result = try await apolloClient.fetch(query: query)
      guard let data = result.data else {
        throw BuildingServiceError.invalidResponse
      }
      graphQLBuildings = data.buildings
    }
    
    // Convert buildings from GraphQL rep
    var buildings = graphQLBuildings.compactMap(Building.init(from:))
    
    // Update buildings with ratings
    await fetchBuildingRatings(into: &buildings)
    
    return buildings
  }
  
  private func fetchBuildingStatuses(into buildings: inout [Building]) async {
    let statusEndpoint = endpoints.backend
      .appending(component: "rooms")
      .appending(component: "status")
    
    
    let status: [String : Int]
    do {
      let data = try await httpSession.data(from: statusEndpoint)
      let remoteStatus = try DevSoc.jsonDecoder.decode(RemoteBuildingStatus.self, from: data)
    } catch {
      // Give up, don't update status
    }
    
  }
  
  private func fetchBuildingRatings(into buildings: inout [Building]) async {
    let ratingsEndpoint = endpoints.backend.appending(component: "buildingRating")
    
    // Fetch the rating for each building
    let ratings = await withTaskGroup(of: RemoteBuildingRatingResponse?.self) { group in
      for b in buildings {
        group.addTask {
          
          // Create the endpoint for each building
          let endpoint = ratingsEndpoint.appending(component: b.id)
          do {
            
            // Fetch rating from the server and attempt to validate
            let (data, _) = try await self.httpSession.data(from: endpoint)
            let rating = try DevSoc.jsonDecoder.decode(RemoteBuildingRatingResponse.self, from: data)
            assert(rating.buildingId == b.id, "Building id mismatch between response and request")
            
            return rating
          } catch {
            // If we can't fetch or decode the rating, just don't show it
            return nil
          }
          
        }
      }
      
      // Combine rating requests
      var ratings: [Building.ID : Double] = [:]
      for await rating in group {
        guard let rating else { continue }
        assert(!ratings.keys.contains(rating.buildingId))
        ratings[rating.buildingId] = rating.overallRating
      }
      
      return ratings
    }
    
    // Update buildings with fetched ratings
    for i in buildings.indices {
      if let rating = ratings[buildings[i].id] {
        buildings[i].overallRating = rating
      }
    }
    
  }
  
}

/// Errors that can occur when fetching `Building`s
public enum BuildingServiceError: Error, LocalizedError {
  
  /// The `GraphQL` endpoint did not provide a valid response
  case invalidResponse
  
  public var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "Invalid response from server"
    }
  }
  
}

/*

public typealias GetBuildingsResult = Swift.Result<[Building], FetchBuildingsError>

// MARK: - FetchBuildingsError

public enum FetchBuildingsError: Error {
  case connectivity
}

extension FetchBuildingsError {
  public var clientMessage: String {
    switch self {
    case .connectivity:
      "Failed to fetch buildings. Please check your internet connection."
    }
  }
}

// MARK: - BuildingService

@GenerateStub
public protocol BuildingService {
  func getBuildings() async -> GetBuildingsResult
}

// MARK: - LiveBuildingService

public final class LiveBuildingService: BuildingService {

  // MARK: Lifecycle

  public init(buildingLoader: any BuildingLoader) {
    self.buildingLoader = buildingLoader
  }

  // MARK: Public

  public typealias GetBuildingsResult = Swift.Result<[Building], FetchBuildingsError>

  public func getBuildings() async -> GetBuildingsResult {
    switch await buildingLoader.fetch() {
    case .success(let buildings):
      .success(buildings)
    case .failure:
      .failure(.connectivity)
    }
  }

  // MARK: Private

  private var buildingLoader: any BuildingLoader
}

// MARK: - PreviewBuildingService

public final class PreviewBuildingService: BuildingService {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func getBuildings() -> GetBuildingsResult {
    .success([
      Building(name: "AGSM", id: "K-E4", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 1),
      Building(name: "Biological Sciences", id: "K-E8", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 2),
      Building(
        name: "Biological Sciences (West)",
        id: "K-E10",
        latitude: 0,
        longitude: 0,
        aliases: [],
        numberOfAvailableRooms: 3),
      Building(name: "Matthews Building", id: "K-E12", latitude: 0, longitude: 0, aliases: [], numberOfAvailableRooms: 4),
      Building(
        name: "Morven Brown Building",
        id: "K-C20",
        latitude: -33.916792,
        longitude: 151.232828,
        aliases: [],
        numberOfAvailableRooms: nil),
      Building(
        name: "Wallace Wurth Building",
        id: "K-B16",
        latitude: -33.916744,
        longitude: 151.235681,
        aliases: [],
        numberOfAvailableRooms: nil),
    ])
  }

  public func reloadBuildings() -> GetBuildingsResult {
    getBuildings()
  }
}

*/
