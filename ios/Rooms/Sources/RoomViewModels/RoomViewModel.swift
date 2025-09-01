//
//  RoomViewModel.swift
//  Rooms
//
//  Created by Yanlin Li  on 6/8/2025.
//

import Foundation
import Location
import Observation
import RoomInteractors
import RoomModels
import RoomServices

// MARK: - RoomViewModel

public protocol RoomViewModel {
  var buildingId: String? { get set }

  var rooms: [Room] { get set }

  var roomsInAscendingOrder: Bool { get }

  var isLoading: Bool { get }

  func getRoomsInOrder()

  func onAppear()

}

// MARK: - RoomInteractor

// TODO: change this to live room interactor!
public class RoomInteractor {

  // MARK: Lifecycle

  public init(buildingId: String, roomService: RoomService, locationService: LocationService) {
    self.buildingId = buildingId
    self.roomService = roomService
    self.locationService = locationService
  }

  public init(roomService: RoomService, locationService: LocationService) {
    self.roomService = roomService
    self.locationService = locationService
    buildingId = ""
  }

  // MARK: Public

  public func sortRoomsInOrder(rooms: [Room], order: Bool) -> [Room] {
    rooms.sorted { a, b in
      order ? a.name < b.name : a.name > b.name
    }
  }

  public func getRoomsSortedAlphabetically(inAscendingOrder: Bool) -> Result<[Room], Error> {
    switch roomService.getRooms(buildingId: buildingId) {
    case .success(let rooms):
      let sorted = rooms.sorted { a, b in
        inAscendingOrder ? a.name < b.name : a.name > b.name
      }
      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  public func getAllRoomsSortedAlphabetically(inAscendingOrder: Bool) -> Result<[Room], Error> {
    switch roomService.getRooms() {
    case .success(let rooms):
      let sorted = rooms.sorted { a, b in
        inAscendingOrder ? a.name < b.name : a.name > b.name
      }
      return .success(sorted)

    case .failure(let error):
      return .failure(error)
    }
  }

  // MARK: Private

  private let buildingId: String
  private let roomService: RoomService
  private let locationService: LocationService
}

// MARK: - LiveRoomViewModel

@Observable
// swiftlint:disable:next no_unchecked_sendable
public class LiveRoomViewModel: RoomViewModel, @unchecked Sendable {

  // MARK: Lifecycle

  public init(interactor: RoomInteractor) {
    self.interactor = interactor
    buildingId = "123"
  }

  // MARK: Public

  public var buildingId: String?

  public var rooms: [Room] = []

  public var roomsInAscendingOrder = true

  public var isLoading = false

  public func getLoadingStatus() -> Bool {
    isLoading
  }

  public func onAppear() {
    // Load Rooms when the view appears
    loadRooms()
  }

  /// New method to load Rooms asynchronously
  public func loadRooms() {
    isLoading = true

    let result = interactor.getAllRoomsSortedAlphabetically(inAscendingOrder: roomsInAscendingOrder)

    switch result {
    case .success(let roomsData):
      rooms = interactor.sortRoomsInOrder(rooms: roomsData, order: roomsInAscendingOrder)
    case .failure(let error):
      // swiftlint:disable:next no_direct_standard_out_logs
      print("Error loading rooms: \(error)")
    }

    isLoading = false
  }

  public func getRoomsInOrder() {
    isLoading = true
    roomsInAscendingOrder.toggle()
    rooms = interactor.sortRoomsInOrder(rooms: rooms, order: roomsInAscendingOrder)
    isLoading = false
  }

  // MARK: Private

  private var interactor: RoomInteractor

}

// MARK: - PreviewRoomViewModel

@Observable
// swiftlint:disable:next no_unchecked_sendable
public class PreviewRoomViewModel: LiveRoomViewModel, @unchecked Sendable {

  public init() {
    super.init(interactor: RoomInteractor(
      buildingId: "K-B16",
      roomService: PreviewRoomService(),
      locationService: LocationService(locationManager: LiveLocationManager())))
  }
}
