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
  var rooms: [Room] { get set }

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

  public init() { }

  // MARK: Public

  public var rooms: [Room] = []

  public var roomsInAscendingOrder = false

  public var isLoading = false

  public func getLoadingStatus() -> Bool {
    isLoading
  }

  public func onAppear() {
    // Load Rooms when the view appears
    Task {
      await loadRooms()
    }
  }

  /// New method to load Rooms asynchronously
  public func loadRooms() async {
    isLoading = true

    let mockRooms: [Room] = [
      Room(name: "Ainsworth 801", id: "K-B16", abbreviation: "A-101", capacity: 10, usage: "Goon", school: "UNSW"),
      Room(name: "Ainsworth 201", id: "K-C20", abbreviation: "A-201", capacity: 10, usage: "Goon", school: "UNSW"),
      Room(name: "Ainsworth 301", id: "K-B17", abbreviation: "A-201", capacity: 10, usage: "Goon", school: "UNSW"),
      Room(name: "Ainsworth 101", id: "K-B18", abbreviation: "A-201", capacity: 10, usage: "Goon", school: "UNSW"),
      Room(name: "Ainsworth 501", id: "K-B19", abbreviation: "A-201", capacity: 10, usage: "Goon", school: "UNSW"),
    ]
    rooms = sortRoomsInOrder(rooms: mockRooms, order: roomsInAscendingOrder)

    isLoading = false
  }

  public func getRoomsInOrder() {
    isLoading = true
    roomsInAscendingOrder.toggle()

    rooms = sortRoomsInOrder(rooms: rooms, order: roomsInAscendingOrder)

    // Simulate delay from fetching buildings
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }

      isLoading = false
    }
  }

  // MARK: Private

//  private var interactor: RoomInteractor

  private func sortRoomsInOrder(rooms: [Room], order: Bool) -> [Room] {
    rooms.sorted { a, b in
      order ? a.name < b.name : a.name > b.name
    }
  }

}
