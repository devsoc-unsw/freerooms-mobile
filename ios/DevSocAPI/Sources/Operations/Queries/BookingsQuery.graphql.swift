// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct BookingsQuery: GraphQLQuery {
  public static let operationName: String = "Bookings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query Bookings($start: timestamptz!, $end: timestamptz!, $offset: Int!, $limit: Int!) { bookings( where: { _and: [{ start: { _lt: $end } }, { end: { _gt: $start } }] } order_by: [{ start: asc }] offset: $offset limit: $limit ) { __typename name eventId occurrenceId bookingType roomId start end room { __typename name abbr usage capacity building { __typename id name } } } }"#
    ))

  public var start: Timestamptz
  public var end: Timestamptz
  public var offset: Int32
  public var limit: Int32

  public init(
    start: Timestamptz,
    end: Timestamptz,
    offset: Int32,
    limit: Int32
  ) {
    self.start = start
    self.end = end
    self.offset = offset
    self.limit = limit
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "start": start,
    "end": end,
    "offset": offset,
    "limit": limit
  ] }

  nonisolated public struct Data: DevSocAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Query_root }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("bookings", [Booking].self, arguments: [
        "where": ["_and": [["start": ["_lt": .variable("end")]], ["end": ["_gt": .variable("start")]]]],
        "order_by": [["start": "asc"]],
        "offset": .variable("offset"),
        "limit": .variable("limit")
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      BookingsQuery.Data.self
    ] }

    /// An array relationship
    public var bookings: [Booking] { __data["bookings"] }

    /// Booking
    ///
    /// Parent Type: `Bookings`
    nonisolated public struct Booking: DevSocAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Bookings }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("eventId", String.self),
        .field("occurrenceId", String.self),
        .field("bookingType", DevSocAPI.Bookingtypeenum.self),
        .field("roomId", String.self),
        .field("start", DevSocAPI.Timestamptz.self),
        .field("end", DevSocAPI.Timestamptz.self),
        .field("room", Room.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BookingsQuery.Data.Booking.self
      ] }

      public var name: String { __data["name"] }
      public var eventId: String { __data["eventId"] }
      public var occurrenceId: String { __data["occurrenceId"] }
      public var bookingType: DevSocAPI.Bookingtypeenum { __data["bookingType"] }
      public var roomId: String { __data["roomId"] }
      public var start: DevSocAPI.Timestamptz { __data["start"] }
      public var end: DevSocAPI.Timestamptz { __data["end"] }
      /// An object relationship
      public var room: Room { __data["room"] }

      /// Booking.Room
      ///
      /// Parent Type: `Rooms`
      nonisolated public struct Room: DevSocAPI.SelectionSet {
        @_spi(Unsafe) public let __data: DataDict
        @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

        @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Rooms }
        @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
          .field("abbr", String.self),
          .field("usage", String.self),
          .field("capacity", Int.self),
          .field("building", Building.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          BookingsQuery.Data.Booking.Room.self
        ] }

        public var name: String { __data["name"] }
        public var abbr: String { __data["abbr"] }
        public var usage: String { __data["usage"] }
        public var capacity: Int { __data["capacity"] }
        /// An object relationship
        public var building: Building { __data["building"] }

        /// Booking.Room.Building
        ///
        /// Parent Type: `Buildings`
        nonisolated public struct Building: DevSocAPI.SelectionSet {
          @_spi(Unsafe) public let __data: DataDict
          @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

          @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Buildings }
          @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", String.self),
            .field("name", String.self),
          ] }
          @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
            BookingsQuery.Data.Booking.Room.Building.self
          ] }

          public var id: String { __data["id"] }
          public var name: String { __data["name"] }
        }
      }
    }
  }
}
