// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Buildings",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Buildings",
      targets: ["BuildingViews", "BuildingViewModels", "BuildingInteractors", "BuildingServices"]),
    .library(name: "BuildingModels", targets: ["BuildingModels"]),
    .library(name: "BuildingViews", targets: ["BuildingViews"]),
    .library(name: "BuildingInteractors", targets: ["BuildingInteractors"]),
    .library(name: "BuildingServices", targets: ["BuildingServices"]),
  ],
  dependencies: [
    .package(name: "Networking", path: "../Networking"),
    .package(name: "Location", path: "../Location"),
    .package(name: "CommonUI", path: "../CommonUI"),
    .package(name: "Persistence", path: "../Persistence"),
    .package(name: "Rooms", path: "../Rooms"),
    .package(name: "TestingSupport", path: "../TestingSupport"),
    .package(name: "DevSocAPI", path: "../DevSocAPI"),
    .package(url: "https://github.com/lucaszischka/BottomSheet", from: "3.1.1"),
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "8.0.0"),
    .package(url: "https://github.com/apollographql/apollo-ios.git", from: "2.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "BuildingViews",
      dependencies: [
        "BuildingViewModels",
        "CommonUI",
        "BuildingModels",
        .product(name: "RoomInteractors", package: "Rooms"),
        .product(name: "RoomViewModels", package: "Rooms"),
        .product(name: "BottomSheet", package: "BottomSheet"),
      ],
      resources: [.process("Resources")],
      swiftSettings: swiftSettings),
    .target(
      name: "BuildingViewModels",
      dependencies: [
        "BuildingInteractors",
        "BuildingModels",
        "CommonUI",
        .product(name: "RoomInteractors", package: "Rooms"),
        .product(name: "BottomSheet", package: "BottomSheet"),
      ],
      swiftSettings: swiftSettings),
    .target(
      name: "BuildingInteractors",
      dependencies: ["BuildingServices", "Location", "BuildingModels", .product(name: "RoomServices", package: "Rooms")],
      swiftSettings: swiftSettings),
    .target(
      name: "BuildingServices",
      dependencies: [
        "Networking",
        "Persistence",
        "BuildingModels",
        .product(name: "RoomServices", package: "Rooms"),
        .product(name: "VISOR", package: "VISOR"),
        .product(name: "DevSocAPI", package: "DevSocAPI"),
      ],
      swiftSettings: swiftSettings),
    .target(
      name: "BuildingModels",
      dependencies: ["Persistence", "Location", .product(name: "RoomModels", package: "Rooms")],
      swiftSettings: swiftSettings),
    .testTarget(
      name: "BuildingsTests",
      dependencies: [
        "BuildingServices",
        "BuildingInteractors",
        "BuildingModels",
        "Persistence",
        "TestingSupport",
        .product(name: "RoomServices", package: "Rooms"),
        .product(name: "PersistenceTestUtils", package: "Persistence"),
        .product(name: "Location", package: "Location"),
        .product(name: "NetworkingTestUtils", package: "Networking"),
      ],
      swiftSettings: swiftSettings),
  ])

let swiftSettings: [SwiftSetting] = [
  .defaultIsolation(nil),
  .strictMemorySafety(),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("ImmutableWeakCaptures"),
]
