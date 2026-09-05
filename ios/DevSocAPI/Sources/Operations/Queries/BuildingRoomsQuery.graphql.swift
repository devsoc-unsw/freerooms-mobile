// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct BuildingRoomsQuery: GraphQLQuery {
  public static let operationName: String = "BuildingRooms"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query BuildingRooms($buildingId: String!) { rooms(where: { buildingId: { _eq: $buildingId } }) { __typename abbr accessibility audiovisual capacity floor id infotechnology lat long microphone name school seating service usage writingMedia buildingId } }"#
    ))

  public var buildingId: String

  public init(buildingId: String) {
    self.buildingId = buildingId
  }

  @_spi(Unsafe) public var __variables: Variables? { ["buildingId": buildingId] }

  nonisolated public struct Data: DevSocAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Query_root }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("rooms", [Room].self, arguments: ["where": ["buildingId": ["_eq": .variable("buildingId")]]]),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      BuildingRoomsQuery.Data.self
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
        .field("accessibility", [DevSocAPI._Text].self),
        .field("audiovisual", [DevSocAPI._Text].self),
        .field("capacity", Int.self),
        .field("floor", DevSocAPI.Floortypeenum?.self),
        .field("id", String.self),
        .field("infotechnology", [DevSocAPI._Text].self),
        .field("lat", DevSocAPI.Float8.self),
        .field("long", DevSocAPI.Float8.self),
        .field("microphone", [DevSocAPI._Text].self),
        .field("name", String.self),
        .field("school", String.self),
        .field("seating", DevSocAPI.Seatingtypeenum?.self),
        .field("service", [DevSocAPI._Text].self),
        .field("usage", String.self),
        .field("writingMedia", [DevSocAPI._Text].self),
        .field("buildingId", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        BuildingRoomsQuery.Data.Room.self
      ] }

      public var abbr: String { __data["abbr"] }
      public var accessibility: [DevSocAPI._Text] { __data["accessibility"] }
      public var audiovisual: [DevSocAPI._Text] { __data["audiovisual"] }
      public var capacity: Int { __data["capacity"] }
      public var floor: DevSocAPI.Floortypeenum? { __data["floor"] }
      public var id: String { __data["id"] }
      public var infotechnology: [DevSocAPI._Text] { __data["infotechnology"] }
      public var lat: DevSocAPI.Float8 { __data["lat"] }
      public var long: DevSocAPI.Float8 { __data["long"] }
      public var microphone: [DevSocAPI._Text] { __data["microphone"] }
      public var name: String { __data["name"] }
      public var school: String { __data["school"] }
      public var seating: DevSocAPI.Seatingtypeenum? { __data["seating"] }
      public var service: [DevSocAPI._Text] { __data["service"] }
      public var usage: String { __data["usage"] }
      public var writingMedia: [DevSocAPI._Text] { __data["writingMedia"] }
      public var buildingId: String { __data["buildingId"] }
    }
  }
}
