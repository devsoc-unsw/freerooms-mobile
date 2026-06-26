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

@MainActor
public protocol RoomViewModel: AnyObject {
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
  var selectedDate: Date { get set }
  var selectedRoomTypes: Set<RoomType> { get set }
  var selectedDuration: Duration? { get set }
  var selectedCampusLocation: CampusLocation? { get set }
  var selectedCapacity: Int? { get set }
  var hasActiveFilters: Bool { get }
  var searchText: String { get set }

  var loadRoomErrorMessage: AlertError? { get set }

  func getDisplayedRooms(for buildingId: String) -> [Room]

  func getPlaceHolderRooms(for buildingId: String) -> [Room]

  func getRoomsInOrder()

  func onAppear() async

  func getRoomBookings(roomId: String) async

  func clearRoomBookings()

  func reloadRooms() async

  var currentRoomRating: RoomRating? { get }

  var getRatingIsLoading: Bool { get }

  func fetchRoomRating(roomID: String) async

  func clearRoomRating()

  func applyFilters() async
  func loadBookingsForFilteredRooms() async
  func clearAllFilters()

  func clearDurationFilter()
  func clearDateFilter()
  func clearCampusLocationFilter()
  func clearCapacityFilter()
  func clearRoomTypeFilter()

  var scrollID: Int? { get set }
  var baseDate: Date { get set }
  var dateSelect: Date { get set }

  func resetBookingScrollState(initialDate: Date)
  func handleScrollIDChange(oldValue: Int?, newValue: Int?)
  func handleDateSelectChange(oldValue: Date, newValue: Date)
}

// MARK: - LiveRoomViewModel

@MainActor
@Observable
public class LiveRoomViewModel: RoomViewModel {

  // MARK: Lifecycle

  public init(interactor: RoomInteractor) {
    self.interactor = interactor
  }

  // MARK: Public

  public var scrollID: Int? = RoomBookingConstants.middleIndex
  public var baseDate = Date()
  public var dateSelect = Date()

  public var loadRoomErrorMessage: AlertError?

  public var getBookingsIsLoading = false

  public var getRatingIsLoading = false

  /// Bookings for the **last** room that `getRoomBookings(roomId:)` loaded (e.g. detail / list UI).
  public var currentRoomBookings = [RoomBooking]()

  public var currentRoomRating: RoomRating?

  /// Cached bookings per `Room.id` for duration filtering. Rooms without an entry are not filtered out by duration until their bookings are loaded.
  public var bookingsByRoomId = [String: [RoomBooking]]()

  public var hasLoaded = false

  public var roomsByBuildingId = [String: [RoomModels.Room]]()

  public var rooms = [Room]()

  public var roomsInAscendingOrder = true

  public var isLoading = false

  public var searchText = ""

  public var selectedDate: Date = DateDefaults.selectedDate
  public var selectedRoomTypes: Set<RoomType> = []
  public var selectedDuration: Duration?
  public var selectedCampusLocation: CampusLocation?
  public var selectedCapacity: Int?

  public var hasActiveFilters: Bool {
    selectedDate != DateDefaults.selectedDate ||
      !selectedRoomTypes.isEmpty ||
      selectedDuration != nil ||
      selectedCampusLocation != nil ||
      selectedCapacity != nil
  }

  public var filteredRoomsByBuildingId: [String: [Room]] {
    var result = [String: [Room]]()
    for (buildingId, rooms) in roomsByBuildingId {
      let filteredRooms = interactor.applyClientSideFilters(rooms: rooms, campusLocation: selectedCampusLocation)

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

  public func getPlaceHolderRooms(for buildingId: String) -> [Room] {
    (0..<6).map { index in
      Room(
        abbreviation: "LDG",
        accessibility: ["Loading"],
        audioVisual: ["Loading"],
        buildingId: buildingId,
        capacity: 50,
        floor: "1",
        id: "\(buildingId)-placeholder-\(index)",
        infoTechnology: ["Loading"],
        latitude: 0.0,
        longitude: 0.0,
        microphone: ["Loading"],
        name: "Loading Room Name",
        school: "UNSW",
        seating: "Movable",
        usage: "TUSM",
        service: ["Loading"],
        writingMedia: ["Whiteboard"],
        status: .available,
        endTime: nil,
        overallRating: 4.0)
    }
  }

  public func getDisplayedRooms(for buildingId: String) -> [Room] {
    // If loading and this building has no rooms yet, show placeholders
    if isLoading, roomsByBuildingId[buildingId]?.isEmpty ?? true {
      return getPlaceHolderRooms(for: buildingId)
    }

    // Otherwise show filtered rooms (or empty array if none)
    return filteredRoomsByBuildingId[buildingId] ?? []
  }

  public func clearRoomBookings() {
    currentRoomBookings = []
  }

  public func getLoadingStatus() -> Bool {
    isLoading
  }

  public func onAppear() async {
    // if it has been loaded dont load rooms again
    if !hasLoaded {
      await loadRooms()
    }
    hasLoaded = true
  }

  public func loadRooms() async {
    isLoading = true
    defer { isLoading = false }

    switch await interactor.getRoomsSortedAlphabetically(inAscendingOrder: roomsInAscendingOrder) {
    case .success(let roomsData):
      rooms = interactor.getRoomsSortedAlphabetically(rooms: roomsData, inAscendingOrder: roomsInAscendingOrder)
      roomsByBuildingId = Dictionary(grouping: roomsData, by: \.buildingId)
      for key in roomsByBuildingId.keys {
        roomsByBuildingId[key] = interactor.getRoomsSortedAlphabetically(
          rooms: roomsByBuildingId[key] ?? [Room.exampleOne],
          inAscendingOrder: roomsInAscendingOrder)
      }

    case .failure(let error):
      loadRoomErrorMessage = AlertError(message: error.clientMessage)
      rooms = []
      roomsByBuildingId = [:]
    }
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
      bookingsByRoomId[roomId] = bookings

    case .failure(let error):
      loadRoomErrorMessage = AlertError(message: error.clientMessage)
    }
  }

  public func fetchRoomRating(roomID: String) async {
    currentRoomRating = nil
    getRatingIsLoading = true

    defer {
      self.getRatingIsLoading = false
    }

    switch await interactor.getRoomRating(roomID: roomID) {
    case .success(let rating):
      currentRoomRating = rating
    case .failure(let error):
      loadRoomErrorMessage = AlertError(message: error.clientMessage)
    }
  }

  public func clearRoomRating() {
    currentRoomRating = nil
  }

  public func reloadRooms() async {
    await loadRooms()
  }

  public func applyFilters() async {
    isLoading = true
    defer { isLoading = false }

    switch await interactor.getFilteredRooms(options: currentFilterOptions) {
    case .success(let rooms):
      self.rooms = rooms
      roomsByBuildingId = Dictionary(grouping: rooms, by: \.buildingId)

    case .failure(let error):
      loadRoomErrorMessage = AlertError(message: error.clientMessage)
    }
  }

  public func loadBookingsForFilteredRooms() async {
    let roomIds = roomsByBuildingId.values
      .flatMap { $0 }
      .map(\.id)
      .filter { bookingsByRoomId[$0] == nil }

    guard !roomIds.isEmpty else { return }

    for roomId in roomIds {
      switch await interactor.getRoomBookings(roomID: roomId) {
      case .success(let bookings):
        bookingsByRoomId[roomId] = bookings
      case .failure:
        break
      }
    }
  }

  public func clearAllFilters() {
    DateDefaults.selectedDate = Date()
    selectedDate = DateDefaults.selectedDate
    selectedRoomTypes.removeAll()
    selectedDuration = nil
    selectedCampusLocation = nil
    selectedCapacity = nil
    bookingsByRoomId = [:]
    currentRoomBookings = []
  }

  public func clearDurationFilter() {
    selectedDuration = nil
  }

  public func clearDateFilter() {
    DateDefaults.selectedDate = Date()
    selectedDate = DateDefaults.selectedDate
  }

  public func clearCampusLocationFilter() {
    selectedCampusLocation = nil
  }

  public func clearCapacityFilter() {
    selectedCapacity = nil
  }

  public func clearRoomTypeFilter() {
    selectedRoomTypes.removeAll()
  }

  /// Resets date for room booking list view.
  public func resetBookingScrollState(initialDate: Date) {
    baseDate = initialDate
    dateSelect = initialDate
    scrollID = RoomBookingConstants.middleIndex
  }

  /// Handles horizontal scroll to change the date for room booking list view.
  public func handleScrollIDChange(oldValue: Int?, newValue: Int?) {
    guard let newValue, let oldValue, abs(newValue - oldValue) == 1 else { return }
    dateSelect = baseDate + (Double(newValue - RoomBookingConstants.middleIndex) * .day)
  }

  /// Handles date picker changes for the room booking list view.
  public func handleDateSelectChange(oldValue _: Date, newValue: Date) {
    let currentScroll = scrollID ?? RoomBookingConstants.middleIndex
    let expectedDate = baseDate + (Double(currentScroll - RoomBookingConstants.middleIndex) * .day)

    if abs(newValue.timeIntervalSince(expectedDate)) > 1 {
      baseDate = newValue
      scrollID = RoomBookingConstants.middleIndex
    }
  }

  // MARK: Private

  private let interactor: RoomInteractor

  private var currentFilterOptions: FilterRoomOptions { FilterRoomOptions.make(
    selectedDate: selectedDate,
    selectedRoomTypes: selectedRoomTypes,
    selectedDuration: selectedDuration,
    selectedCapacity: selectedCapacity) }
}

// MARK: - PreviewRoomViewModel

public class PreviewRoomViewModel: LiveRoomViewModel {

  public init() {
    super.init(interactor: RoomInteractor(
      roomService: PreviewRoomService(),
      locationService: LiveLocationService(locationManager: LiveLocationManager())))
  }
}

extension Double {
  public static let day: Double = 86_400
}

// MARK: - RoomBookingConstants

public enum RoomBookingConstants {
  public static let middleIndex = 500
}
