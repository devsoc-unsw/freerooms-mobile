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

public protocol RoomViewModel: Sendable {
  var rooms: [Room] { get set }

  var roomsByBuildingId: [String: [Room]] { get set }

  var filteredRoomsByBuildingId: [String: [Room]] { get }

  var roomsInAscendingOrder: Bool { get }

  var currentRoomBookings: [RoomBooking] { get }

  // TODO: Why is there two loading?
  var isLoading: Bool { get }

  var hasLoaded: Bool { get }

  var getBookingsIsLoading: Bool { get }

  // Filter properties
  var selectedDate: Date? { get set }
  var selectedStartTime: Date? { get set }
  var selectedRoomTypes: Set<RoomType> { get set }
  var selectedDuration: Duration? { get set }
  var selectedCampusLocation: CampusLocation? { get set }
  var selectedCapacity: Int? { get set }
  var hasActiveFilters: Bool { get }
  var searchText: String { get set }

  func getRoomsInOrder()

  func onAppear() async

  func getRoomBookings(roomId: String) async

  func clearRoomBookings()

  func applyFilters()
  func clearAllFilters()
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

  public var getBookingsIsLoading = false

  public var currentRoomBookings: [RoomBooking] = []

  public var hasLoaded = false

  public var roomsByBuildingId: [String: [RoomModels.Room]] = [:]

  public var rooms: [Room] = []

  public var roomsInAscendingOrder = true

  public var isLoading = false

  public var isLoading = false

  public var searchText = ""
  public var selectedDate: Date?
  public var selectedStartTime: Date?
  public var selectedRoomTypes: Set<RoomType> = []
  public var selectedDuration: Duration?
  public var selectedCampusLocation: CampusLocation?
  public var selectedCapacity: Int?

  public var hasActiveFilters: Bool {
    selectedDate != nil ||
      selectedStartTime != nil ||
      !selectedRoomTypes.isEmpty ||
      selectedDuration != nil ||
      selectedCampusLocation != nil ||
      selectedCapacity != nil
  }

  public var filteredRoomsByBuildingId: [String: [Room]] {
    var result: [String: [Room]] = [:]
    for (buildingId, rooms) in roomsByBuildingId {
      var filteredRooms = rooms
      if hasActiveFilters {
        filteredRooms = interactor.applyFilters(rooms: rooms, filter: currentFilter)
      }
      let sortedRooms = interactor.getRoomsSortedAlphabetically(
        rooms: filteredRooms,
        inAscendingOrder: roomsInAscendingOrder)
      let searchedRooms = interactor.filterRoomsByQueryString(sortedRooms, by: searchText)

      if !searchedRooms.isEmpty {
        result[buildingId] = searchedRooms
      }
    }
    return result
  }

  public func clearRoomBookings() {
    currentRoomBookings = []
  }

  public func getLoadingStatus() -> Bool {
    isLoading
  }

  public func onAppear() async {
    // Load Rooms when the view appears
    await loadRooms()
    hasLoaded = true
  }

  public func loadRooms() async {
    isLoading = true

    let resultRooms = await interactor.getRoomsSortedAlphabetically(inAscendingOrder: roomsInAscendingOrder)
    switch resultRooms {
    case .success(let roomsData):
      rooms = interactor.getRoomsSortedAlphabetically(rooms: roomsData, inAscendingOrder: roomsInAscendingOrder)
    case .failure(let error):
      // swiftlint:disable:next no_direct_standard_out_logs
      fatalError("Error loading rooms: \(error)")
    }

    let resultRoomsByBuildingId = await interactor.getRoomsFilteredByAllBuildingId()
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

  public func getRoomBookings(roomId: String) async {
    getBookingsIsLoading = true

    defer {
      self.getBookingsIsLoading = false
    }

    switch await interactor.getRoomBookings(roomID: roomId) {
    case .success(let bookings):
      currentRoomBookings = bookings
    case .failure(let error):
      // TODO: better error handling
      // either an emtpy timetable
      // or display no connection on the timetable
      fatalError("Error loading rooms: \(error)")
    }
  }

  public func applyFilters() {
    // Trigger UI update by accessing filteredRoomsByBuildingId
    _ = filteredRoomsByBuildingId
  }

  public func clearAllFilters() {
    selectedDate = nil
    selectedStartTime = nil
    selectedRoomTypes.removeAll()
    selectedDuration = nil
    selectedCampusLocation = nil
    selectedCapacity = nil
  }

  // MARK: Private

  private let interactor: RoomInteractor

  private var currentFilter: RoomFilter {
    RoomFilter(
      selectedDate: selectedDate,
      selectedStartTime: selectedStartTime,
      selectedRoomTypes: selectedRoomTypes,
      selectedDuration: selectedDuration,
      selectedCampusLocation: selectedCampusLocation,
      selectedCapacity: selectedCapacity)
  }
}

// MARK: - PreviewRoomViewModel

@Observable
// swiftlint:disable:next no_unchecked_sendable
public class PreviewRoomViewModel: LiveRoomViewModel, @unchecked Sendable {

  public init() {
    super.init(interactor: RoomInteractor(
      roomService: PreviewRoomService(),
      locationService: LiveLocationService(locationManager: LiveLocationManager())))

    currentRoomBookings = [RoomBooking.exampleOne, RoomBooking.exampleTwo]
  }
}
