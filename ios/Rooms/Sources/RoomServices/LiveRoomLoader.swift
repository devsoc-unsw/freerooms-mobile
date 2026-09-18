//
//  LiveRoomLoader.swift
//  Rooms
//
//  Created by Muqueet Mohsen Chowdhury on 6/8/2025.
//

public import Apollo
import DevSocAPI
import Foundation
import Networking
import Observation
import Persistence
public import RoomModels
import VISOR
public import VISORTestDoubles

// MARK: - RoomLoaderError

public enum RoomLoaderError: Error {
  case connectivity
  case noDataAvailable
  case malformedJSON, fileNotFound
  case persistenceError
  case alreadySeeded
}

// MARK: - RoomLoader

@GenerateStub
public protocol RoomLoader {
  func fetch(buildingId: String) async -> Result<[Room], RoomLoaderError>
  func fetch() async -> Result<[Room], RoomLoaderError>
}

// MARK: - LiveGraphQLRoomLoader

public final actor LiveGraphQLRoomLoader: RoomLoader {

  // MARK: Lifecycle

  /// I can't find a way to mark the actor initializer as nonisolated
  public init(
    client: ApolloClient,
    roomStatusLoader: (any RoomStatusLoader)?)
  {
    self.client = client
    self.roomStatusLoader = roomStatusLoader
  }

  // MARK: Public

  /// The default ``LiveGraphQLRoomLoader``
  ///
  /// This is intended to be used by extensions, such as intent and widget extensions.
  public static let `default`: LiveGraphQLRoomLoader = {
    let session = URLSession(configuration: .default)
    let store = ApolloStore()
    let client = DevSoc.createLiveApolloClient(using: store, urlSession: session)
    let httpClient = URLSessionHTTPClient(session: session)

    return LiveGraphQLRoomLoader(
      client: client,
      roomStatusLoader: LiveRoomStatusLoader(
        client: httpClient,
        baseURL: DevSoc.defaultBackendURL))
  }()

  public let client: ApolloClient
  public let roomStatusLoader: (any RoomStatusLoader)?

  public func fetch() async -> Result<[Room], RoomLoaderError> {
    // Currently no caching is performed
    let query = AllRoomsQuery()
    do {
      let result = try await client.fetch(query: query)
      guard let data = result.data else {
        return .failure(.noDataAvailable)
      }
      // Convert the rooms
      var rooms = data.rooms.compactMap(Room.init(from:))
      await _combineRoomStatuses(into: &rooms)
      return .success(rooms)
    } catch {
      return .failure(.connectivity)
    }
  }

  public func fetch(buildingId: String) async -> Result<[Room], RoomLoaderError> {
    let query = BuildingRoomsQuery(buildingId: buildingId)
    do {
      let result = try await client.fetch(query: query)
      guard let data = result.data else {
        return .failure(.noDataAvailable)
      }
      // Convert the rooms
      var rooms = data.rooms.compactMap(Room.init(from:))
      await _combineRoomStatuses(into: &rooms)
      return .success(rooms)
    } catch {
      return .failure(.connectivity)
    }
  }

  // MARK: Private

  private func _combineRoomStatuses(into rooms: inout [Room]) async {
    guard let roomStatusLoader else { return }

    guard case .success(let roomStatuses) = await roomStatusLoader.fetchRoomStatus() else {
      return
    }

    // Tuples are not Hashable yet, even if members are Hashable
    struct RoomKey: Hashable {
      let buildingId: String
      let roomId: String
    }
    let collected = [RoomKey: RoomStatus](uniqueKeysWithValues: roomStatuses.flatMap { buildingId, buildingRoomStatus in
      buildingRoomStatus.roomStatuses.map { roomId, roomStatus in
        (RoomKey(buildingId: buildingId, roomId: roomId), roomStatus)
      }
    })

    let dateFormatStyle = Date.ISO8601FormatStyle()
    for i in rooms.indices {
      guard let roomStatus = collected[RoomKey(buildingId: rooms[i].buildingId, roomId: rooms[i].roomNumber)] else { continue }
      rooms[i].status = roomStatus.availability
      rooms[i].endTime = try? dateFormatStyle.parse(roomStatus.endtime)
    }
  }

}

// MARK: - LiveRoomLoader

@available(*, deprecated, message: "Use LiveGraphQLRoomLoader instead")
public final class LiveRoomLoader: RoomLoader {

  // MARK: Lifecycle

  public init(
    JSONRoomLoader: any JSONRoomLoader,
    roomStatusLoader: any RoomStatusLoader,
    swiftDataRoomLoader: any SwiftDataRoomLoader)
  {
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

  private let JSONRoomLoader: any JSONRoomLoader
  private let roomStatusLoader: any RoomStatusLoader
  private let swiftDataRoomLoader: any SwiftDataRoomLoader

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
