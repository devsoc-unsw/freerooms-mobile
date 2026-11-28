//
//  RoomStatusLoader.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 2/9/2025.
//

public import Foundation
public import Networking
public import RoomModels
import VISOR
import VISORTestDoubles

// MARK: - RoomStatusLoaderError

public enum RoomStatusLoaderError: Error, Equatable {
  case connectivity
  case invalidData
}

// MARK: - RoomStatusLoader

@GenerateStub(.sendable)
public protocol RoomStatusLoader: Sendable {
  func fetchRoomStatus() async -> Result<RemoteRoomStatus, RoomStatusLoaderError>
}

// MARK: - LiveRoomStatusLoader

public final class LiveRoomStatusLoader: RoomStatusLoader, Sendable {

  // MARK: Lifecycle

  public init(session: any HTTPSession, baseURL: URL, statusEndpointPath: String = "/api/rooms/status") {
    self.session = session
    self.baseURL = baseURL
    self.statusEndpointPath = statusEndpointPath
  }

  // MARK: Public

  public func fetchRoomStatus() async -> Result<RemoteRoomStatus, RoomStatusLoaderError> {
    guard let url = URL(string: statusEndpointPath, relativeTo: baseURL) else {
      return .failure(.invalidData)
    }
    
    let data: Data
    do {
      let (d, _) = try await session.data(from: url)
      data = d
    } catch {
      return .failure(.connectivity)
    }
    
    do {
      return .success(try DevSoc.jsonDecoder.decode(RemoteRoomStatus.self, from: data))
    } catch {
      return .failure(.invalidData)
    }
    
  }

  // MARK: Private

  private let session: any HTTPSession
  private let baseURL: URL
  private let statusEndpointPath: String
}
