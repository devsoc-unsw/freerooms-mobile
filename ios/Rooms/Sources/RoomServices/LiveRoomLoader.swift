//
//  LiveRoomLoader.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

import Foundation
import Persistence
import RoomModels
import VISOR
import Apollo
import DevSocAPI
import Networking

// MARK: - RoomLoaderError

public enum RoomLoaderError: Error {
  case connectivity
  case noDataAvailable
  case malformedJSON, fileNotFound
  case persistenceError
  case alreadySeeded
}

// MARK: - RoomLoader

// FIXME: Make this nonisolated

@Stubbable
public protocol RoomLoader {
  func fetch(buildingId: String) async -> Result<[Room], RoomLoaderError>
  func fetch() async -> Result<[Room], RoomLoaderError>
}

// MARK: - LiveGraphQLRoomLoader

nonisolated
public final class LiveGraphQLRoomLoader: RoomLoader, Sendable {
  
  public init(
    client: ApolloClient)
  {
    self.client = client
  }
  
  public let client: ApolloClient
  
  public func fetch() async -> Result<[Room], RoomLoaderError> {
    // Currently no caching is performed
    let query = AllRoomsQuery()
    do {
      let result = try await client.fetch(query: query)
      guard let data = result.data else {
        return .failure(.noDataAvailable)
      }
      // Convert the rooms
      let rooms = data.rooms.compactMap(Room.init(from:))
      return .success(rooms)
    } catch {
      return .failure(.connectivity)
    }
  }
  
  public func fetch(buildingId: String) async -> Result<[Room], RoomLoaderError> {
    // Currently no caching is performed
    let query = BuildingRoomsQuery(buildingId: buildingId)
    do {
      let result = try await client.fetch(query: query)
      guard let data = result.data else {
        return .failure(.noDataAvailable)
      }
      // Convert the rooms
      let rooms = data.rooms.compactMap(Room.init(from:))
      return .success(rooms)
    } catch {
      return .failure(.connectivity)
    }
  }
  
}

// MARK: - LiveRoomLoader

@available(*, deprecated, message: "Use LiveGraphQLRoomLoader instead")
public final class LiveRoomLoader: RoomLoader {

  // MARK: Lifecycle

  public init(JSONRoomLoader: JSONRoomLoader, roomStatusLoader: RoomStatusLoader, swiftDataRoomLoader: SwiftDataRoomLoader) {
    self.JSONRoomLoader = JSONRoomLoader
    self.roomStatusLoader = roomStatusLoader
    self.swiftDataRoomLoader = swiftDataRoomLoader
  }

  // MARK: Public

  public typealias Result = Swift.Result<[Room], RoomLoaderError>

  public func fetch(buildingId: String) async -> Result {
    if !hasSavedData {
      switch await JSONRoomLoader.fetch() {
      case .success(let rooms):
        _ = swiftDataRoomLoader.seed(rooms)
        var filteredRooms = rooms.filter { $0.buildingId == buildingId }
        await combineLiveAndSavedData(&filteredRooms)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSavedRoomsData)
        return .success(filteredRooms)

      case .failure(let err):
        return .failure(err)
      }
    } else {
      switch swiftDataRoomLoader.fetch() {
      case .success(let offlineRooms):
        var filteredRooms = offlineRooms.filter { $0.buildingId == buildingId }
        await combineLiveAndSavedData(&filteredRooms)
        return .success(filteredRooms)

      case .failure(let err):
        return .failure(err)
      }
    }
  }

  public func fetch() async -> Result {
    if !hasSavedData {
      switch await JSONRoomLoader.fetch() {
      case .success(var rooms):
        _ = swiftDataRoomLoader.seed(rooms)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSavedRoomsData)
        await combineLiveAndSavedData(&rooms)
        return .success(rooms)

      case .failure(let err):
        return .failure(err)
      }
    } else {
      switch swiftDataRoomLoader.fetch() {
      case .success(var offlineRooms):
        await combineLiveAndSavedData(&offlineRooms)
        return .success(offlineRooms)

      case .failure(let err):
        return .failure(err)
      }
    }
  }

  // MARK: Private

  private static let liveStatusTimeoutNanoseconds: UInt64 = 2_000_000_000

  private let JSONRoomLoader: JSONRoomLoader
  private let roomStatusLoader: RoomStatusLoader
  private let swiftDataRoomLoader: SwiftDataRoomLoader

  private var hasSavedData: Bool {
    UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasSavedRoomsData)
  }

  private func combineLiveAndSavedData(_ rooms: inout [Room]) async {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if case .success(let roomStatusResponse) = await fetchRoomStatusWithTimeout() {
      for i in rooms.indices {
        let roomStatus = roomStatusResponse[rooms[i].buildingId]?.roomStatuses[rooms[i].roomNumber] ?? RoomStatus(
          status: "",
          endtime: "")

        switch roomStatus.status {
        case "free":
          rooms[i].status = .available
        case "soon":
          rooms[i].status = .availableSoon
        case "busy":
          rooms[i].status = .unavailable
        default:
          rooms[i].status = .unknown
        }

        rooms[i].endTime = formatter.date(from: roomStatus.endtime)
      }
    }
  }

  private func fetchRoomStatusWithTimeout() async -> Swift.Result<RemoteRoomStatus, RoomStatusLoaderError> {
    let roomStatusLoader = roomStatusLoader

    return await withTaskGroup(of: Swift.Result<RemoteRoomStatus, RoomStatusLoaderError>.self) { group in
      group.addTask {
        await roomStatusLoader.fetchRoomStatus()
      }

      group.addTask {
        try? await Task.sleep(nanoseconds: Self.liveStatusTimeoutNanoseconds)
        return .failure(.connectivity)
      }

      let result = await group.next() ?? .failure(.connectivity)
      group.cancelAll()
      return result
    }
  }
}
