//
//  WeeklyBooking.swift
//  Bookings
//
//  Created by Yanlin Li  on 7/8/2025.
//

public import DevSocAPI
public import Foundation

public typealias Booking = WeeklyBooking

// MARK: - WeeklyBooking

/// A booking prepared for display in the cross-room weekly discovery feed.
public struct WeeklyBooking: Identifiable, Equatable, Hashable, Sendable {

  // MARK: Lifecycle

  public init(
    title: String,
    eventId: UUID,
    occurrenceId: UUID,
    bookingType: String?,
    roomID: String,
    roomName: String,
    buildingID: String?,
    buildingName: String?,
    start: Date,
    end: Date,
    usage: String,
    capacity: Int,
    abbreviation: String)
  {
    self.title = title
    self.eventId = eventId
    self.occurrenceId = occurrenceId
    self.bookingType = bookingType
    self.roomID = roomID
    self.roomName = roomName
    self.buildingID = buildingID
    self.buildingName = buildingName
    self.start = start
    self.end = end
    self.usage = usage
    self.capacity = capacity
    self.abbreviation = abbreviation
  }

  // MARK: Public

  public let title: String
  public let eventId: UUID
  public let occurrenceId: UUID
  public let bookingType: String?
  public let roomID: String
  public let roomName: String
  public let buildingID: String?
  public let buildingName: String?
  public let start: Date
  public let end: Date
  public let usage: String
  public let capacity: Int
  public let abbreviation: String

  public var id: UUID {
    occurrenceId
  }
}

// MARK: - _GraphQLBookingProtocol

@_documentation(visibility: internal)
public protocol _GraphQLBookingProtocol {
  associatedtype Room: _GraphQLBookingRoomProtocol
  var name: String { get }
  var eventId: String { get }
  var occurrenceId: String { get }
  var bookingType: String { get }
  var roomId: String { get }
  var start: String { get }
  var end: String { get }
  var room: Room { get }
}

// MARK: - _GraphQLBookingRoomProtocol

@_documentation(visibility: internal)
public protocol _GraphQLBookingRoomProtocol {
  associatedtype Building: _GraphQLBookingRoomBuildingProtocol
  var name: String { get }
  var abbr: String { get }
  var usage: String { get }
  var capacity: Int { get }
  var building: Building { get }
}

// MARK: - _GraphQLBookingRoomBuildingProtocol

@_documentation(visibility: internal)
public protocol _GraphQLBookingRoomBuildingProtocol {
  var id: String { get }
  var name: String { get }
}

// MARK: - DevSocAPI.WeeklyBookingsQuery.Data.Booking + _GraphQLBookingProtocol

extension DevSocAPI.WeeklyBookingsQuery.Data.Booking: _GraphQLBookingProtocol { }

// MARK: - DevSocAPI.WeeklyBookingsQuery.Data.Booking.Room + _GraphQLBookingRoomProtocol

extension DevSocAPI.WeeklyBookingsQuery.Data.Booking.Room: _GraphQLBookingRoomProtocol { }

// MARK: - DevSocAPI.WeeklyBookingsQuery.Data.Booking.Room.Building + _GraphQLBookingRoomBuildingProtocol

extension DevSocAPI.WeeklyBookingsQuery.Data.Booking.Room.Building: _GraphQLBookingRoomBuildingProtocol { }

// MARK: - DevSocAPI.BookingsQuery.Data.Booking + _GraphQLBookingProtocol

extension DevSocAPI.BookingsQuery.Data.Booking: _GraphQLBookingProtocol { }

// MARK: - DevSocAPI.BookingsQuery.Data.Booking.Room + _GraphQLBookingRoomProtocol

extension DevSocAPI.BookingsQuery.Data.Booking.Room: _GraphQLBookingRoomProtocol { }

// MARK: - DevSocAPI.BookingsQuery.Data.Booking.Room.Building + _GraphQLBookingRoomBuildingProtocol

extension DevSocAPI.BookingsQuery.Data.Booking.Room.Building: _GraphQLBookingRoomBuildingProtocol { }

extension Booking {

  /// Convert a
  public init(from booking: some _GraphQLBookingProtocol) throws(BookingConversionError) {
    // Used to parse start and end times
    let dateFormatStyle = Date.ISO8601FormatStyle()

    // Try to parse the start and end date
    let startDate: Date
    let endDate: Date
    do {
      startDate = try dateFormatStyle.parse(booking.start)
      endDate = try dateFormatStyle.parse(booking.end)
    } catch {
      throw BookingConversionError.invalidDateFormat(error)
    }

    guard let eventId = UUID(uuidString: booking.eventId) else {
      throw BookingConversionError.invalidEventId(booking.eventId)
    }
    guard let occurrenceId = UUID(uuidString: booking.occurrenceId) else {
      throw BookingConversionError.invalidOccurrenceId(booking.occurrenceId)
    }

    self.init(
      title: booking.name,
      eventId: eventId,
      occurrenceId: occurrenceId,
      bookingType: booking.bookingType,
      roomID: booking.roomId,
      roomName: booking.room.name,
      buildingID: booking.room.building.id,
      buildingName: booking.room.building.name,
      start: startDate,
      end: endDate,
      usage: booking.room.usage,
      capacity: booking.room.capacity,
      abbreviation: booking.room.abbr)
  }
}

// MARK: - BookingConversionError

/// Possible errors that can occur when converting a **GraphQL** booking into
/// a regular ``WeeklyBooking``
public enum BookingConversionError: Error {
  /// Either the start or end date could not be converted into a valid date
  case invalidDateFormat(any Error)
  /// The ``Booking/eventId`` was not a valid `UUID`
  case invalidEventId(String)
  /// The ``Booking/occurrenceId`` was not a valid `UUID`
  case invalidOccurrenceId(String)
}
