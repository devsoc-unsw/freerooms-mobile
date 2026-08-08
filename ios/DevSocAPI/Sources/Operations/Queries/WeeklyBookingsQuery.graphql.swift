// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct WeeklyBookingsQuery: GraphQLQuery {
  public static let operationName: String = "WeeklyBookings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query WeeklyBookings($weekStart: timestamptz!, $weekEnd: timestamptz!) { bookings( where: { _and: [{ start: { _lt: $weekEnd } }, { end: { _gt: $weekStart } }] } order_by: [{ start: asc }] ) { __typename name roomId start end room { __typename name building { __typename id name } } } }"#
    ))

  public var weekStart: Timestamptz
  public var weekEnd: Timestamptz

  public init(
    weekStart: Timestamptz,
    weekEnd: Timestamptz
  ) {
    self.weekStart = weekStart
    self.weekEnd = weekEnd
  }

  @_spi(Unsafe) public var __variables: Variables? { [
    "weekStart": weekStart,
    "weekEnd": weekEnd
  ] }

  nonisolated public struct Data: DevSocAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Query_root }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("bookings", [Booking].self, arguments: [
        "where": ["_and": [["start": ["_lt": .variable("weekEnd")]], ["end": ["_gt": .variable("weekStart")]]]],
        "order_by": [["start": "asc"]]
      ]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      WeeklyBookingsQuery.Data.self
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
        .field("roomId", String.self),
        .field("start", DevSocAPI.Timestamptz.self),
        .field("end", DevSocAPI.Timestamptz.self),
        .field("room", Room.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        WeeklyBookingsQuery.Data.Booking.self
      ] }

      public var name: String { __data["name"] }
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
          .field("building", Building.self),
        ] }
        @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
          WeeklyBookingsQuery.Data.Booking.Room.self
        ] }

        public var name: String { __data["name"] }
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
            WeeklyBookingsQuery.Data.Booking.Room.Building.self
          ] }

          public var id: String { __data["id"] }
          public var name: String { __data["name"] }
        }
      }
    }
  }
}
