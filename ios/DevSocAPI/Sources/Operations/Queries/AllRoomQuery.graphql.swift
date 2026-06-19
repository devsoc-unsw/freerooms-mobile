// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct AllRoomQuery: GraphQLQuery {
  public static let operationName: String = "AllRoom"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query AllRoom { rooms { __typename abbr accessibility audiovisual buildingId capacity floor id infotechnology lat long microphone name school seating service usage writingMedia } }"#
    ))

  public init() {}

  nonisolated public struct Data: DevSocAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Query_root }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("rooms", [Room].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      AllRoomQuery.Data.self
    ] }

    /// An array relationship
    public var rooms: [Room] { __data["rooms"] }

    /// Room
    ///
    /// Parent Type: `Rooms`
    nonisolated public struct Room: DevSocAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Rooms }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("abbr", String.self),
        .field("accessibility", DevSocAPI._Text.self),
        .field("audiovisual", DevSocAPI._Text.self),
        .field("buildingId", String.self),
        .field("capacity", Int.self),
        .field("floor", DevSocAPI.Floortypeenum?.self),
        .field("id", String.self),
        .field("infotechnology", DevSocAPI._Text.self),
        .field("lat", DevSocAPI.Float8.self),
        .field("long", DevSocAPI.Float8.self),
        .field("microphone", DevSocAPI._Text.self),
        .field("name", String.self),
        .field("school", String.self),
        .field("seating", DevSocAPI.Seatingtypeenum?.self),
        .field("service", DevSocAPI._Text.self),
        .field("usage", String.self),
        .field("writingMedia", DevSocAPI._Text.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AllRoomQuery.Data.Room.self
      ] }

      public var abbr: String { __data["abbr"] }
      public var accessibility: DevSocAPI._Text { __data["accessibility"] }
      public var audiovisual: DevSocAPI._Text { __data["audiovisual"] }
      public var buildingId: String { __data["buildingId"] }
      public var capacity: Int { __data["capacity"] }
      public var floor: DevSocAPI.Floortypeenum? { __data["floor"] }
      public var id: String { __data["id"] }
      public var infotechnology: DevSocAPI._Text { __data["infotechnology"] }
      public var lat: DevSocAPI.Float8 { __data["lat"] }
      public var long: DevSocAPI.Float8 { __data["long"] }
      public var microphone: DevSocAPI._Text { __data["microphone"] }
      public var name: String { __data["name"] }
      public var school: String { __data["school"] }
      public var seating: DevSocAPI.Seatingtypeenum? { __data["seating"] }
      public var service: DevSocAPI._Text { __data["service"] }
      public var usage: String { __data["usage"] }
      public var writingMedia: DevSocAPI._Text { __data["writingMedia"] }
    }
  }
}
