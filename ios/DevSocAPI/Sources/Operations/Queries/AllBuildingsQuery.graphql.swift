// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

nonisolated public struct AllBuildingsQuery: GraphQLQuery {
  public static let operationName: String = "AllBuildings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query AllBuildings { buildings { __typename id lat long name } }"#
    ))

  public init() {}

  nonisolated public struct Data: DevSocAPI.SelectionSet {
    @_spi(Unsafe) public let __data: DataDict
    @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

    @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Query_root }
    @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
      .field("buildings", [Building].self),
    ] }
    @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
      AllBuildingsQuery.Data.self
    ] }

    /// fetch data from the table: "buildings"
    public var buildings: [Building] { __data["buildings"] }

    /// Building
    ///
    /// Parent Type: `Buildings`
    nonisolated public struct Building: DevSocAPI.SelectionSet {
      @_spi(Unsafe) public let __data: DataDict
      @_spi(Unsafe) public init(_dataDict: DataDict) { __data = _dataDict }

      @_spi(Execution) public static var __parentType: any ApolloAPI.ParentType { DevSocAPI.Objects.Buildings }
      @_spi(Execution) public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", String.self),
        .field("lat", DevSocAPI.Float8.self),
        .field("long", DevSocAPI.Float8.self),
        .field("name", String.self),
      ] }
      @_spi(Execution) public static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] { [
        AllBuildingsQuery.Data.Building.self
      ] }

      public var id: String { __data["id"] }
      public var lat: DevSocAPI.Float8 { __data["lat"] }
      public var long: DevSocAPI.Float8 { __data["long"] }
      public var name: String { __data["name"] }
    }
  }
}
