//
//  MockRemoteRoomLoader.swift
//  RoomsTests
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

import Foundation
@testable import Rooms

// MARK: - MockRemoteRoomLoader

public class MockRemoteRoomLoader: RemoteRoomLoader {
  
  // MARK: Internal
  
  public func stubRemoteRooms(_ remoteRooms: [RemoteRoom], for buildingId: String) {
    stubbedRemoteRooms[buildingId] = remoteRooms
  }
  
  public func stubError(_ error: RemoteRoomLoaderError) {
    stubbedError = error
  }
  
  public func fetch(buildingId: String) async -> Result<[RemoteRoom], RemoteRoomLoaderError> {
    if let error = stubbedError {
      return .failure(error)
    }
    
    if let remoteRooms = stubbedRemoteRooms[buildingId] {
      return .success(remoteRooms)
    }
    return .failure(.connectivity)
  }
  
  // MARK: Private
  
  private var stubbedRemoteRooms: [String: [RemoteRoom]] = [:]
  private var stubbedError: RemoteRoomLoaderError?
} 