//
//  RoomViewModel.swift
//  Rooms
//
//  Created by Yanlin Li  on 6/8/2025.
//

import BuildingModels
import Foundation
import Location
import Observation
import RoomInteractors
import RoomModels
import RoomServices

// MARK: - RoomViewModel

public protocol RoomViewModel {
  var rooms: [Room] { get set }

  var roomsByBuildingId: [String: [Room]] { get set }

  var roomsInAscendingOrder: Bool { get }

  var isLoading: Bool { get }

  func getRoomsInOrder()

  func onAppear()

}

// MARK: - LiveRoomViewModel

@Observable
// swiftlint:disable:next no_unchecked_sendable
public class LiveRoomViewModel: RoomViewModel, @unchecked Sendable {

  // MARK: Lifecycle

  public init(interactor: RoomInteractor) {
    self.interactor = interactor
  }

  // MARK: Public

  public var roomsByBuildingId: [String: [RoomModels.Room]] = [:]

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

  public func loadRooms() {
    isLoading = true

    let resultRooms = interactor.getRoomsSortedAlphabetically(inAscendingOrder: roomsInAscendingOrder)
    switch resultRooms {
    case .success(let roomsData):
      rooms = interactor.getRoomsSortedAlphabetically(rooms: roomsData, inAscendingOrder: roomsInAscendingOrder)
    case .failure(let error):
      // swiftlint:disable:next no_direct_standard_out_logs
      fatalError("Error loading rooms: \(error)")
    }

    let resultRoomsByBuildingId = interactor.getRoomsFilteredByAllBuildingId()
    switch resultRoomsByBuildingId {
    case .success(let roomsData):
      roomsByBuildingId = roomsData
      for key in roomsByBuildingId.keys {
        roomsByBuildingId[key] = interactor.getRoomsSortedAlphabetically(
          rooms: roomsByBuildingId[key] ?? [Room.exampleOne],
          inAscendingOrder: roomsInAscendingOrder)
      }

    case .failure(let error):
      // swiftlint:disable:next no_direct_standard_out_logs
      fatalError("Error loading rooms: \(error)")
    }

    isLoading = false
  }

  public func getRoomsInOrder() {
    isLoading = true
    roomsInAscendingOrder.toggle()
    for key in roomsByBuildingId.keys {
      roomsByBuildingId[key] = interactor.getRoomsSortedAlphabetically(
        rooms: roomsByBuildingId[key] ?? [Room.exampleOne],
        inAscendingOrder: roomsInAscendingOrder)
    }
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
      roomService: PreviewRoomService(),
      locationService: LiveLocationService(locationManager: LiveLocationManager())))
  }
}
