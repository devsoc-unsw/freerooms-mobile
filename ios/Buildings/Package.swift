// swift-tools-version: 6.1
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
    .library(name: "BuildingTestUtils", targets: ["BuildingTestUtils"]),
  ],
  dependencies: [
    .package(name: "Networking", path: "../Networking"),
    .package(name: "Location", path: "../Location"),
    .package(name: "CommonUI", path: "../CommonUI"),
    .package(name: "Persistence", path: "../Persistence"),
    .package(name: "Rooms", path: "../Rooms"),
    .package(name: "TestingSupport", path: "../TestingSupport"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "BuildingViews",
      dependencies: ["BuildingViewModels", "CommonUI", "BuildingModels"],
      resources: [.process("Resources")]),
    .target(
      name: "BuildingViewModels",
      dependencies: ["BuildingInteractors", "BuildingModels"]),
    .target(
      name: "BuildingInteractors",
      dependencies: ["BuildingServices", "Location", "BuildingModels", .product(name: "RoomServices", package: "Rooms")]),
    .target(
      name: "BuildingServices",
      dependencies: ["Networking", "Persistence", "BuildingModels", .product(name: "RoomServices", package: "Rooms")],
      resources: [.process("Resources")]),
    .target(
      name: "BuildingModels",
      dependencies: ["Persistence", "Location", .product(name: "RoomModels", package: "Rooms")]),
    .target(
      name: "BuildingTestUtils",
      dependencies: ["BuildingModels", "BuildingServices", .product(name: "RoomModels", package: "Rooms")]),
    .testTarget(
      name: "BuildingsTests",
      dependencies: [
        "BuildingServices",
        "BuildingInteractors",
        "BuildingModels",
        "Persistence",
        "TestingSupport",
        "BuildingTestUtils",
        .product(name: "RoomServices", package: "Rooms"),
        .product(name: "PersistenceTestUtils", package: "Persistence"),
        .product(name: "LocationTestsUtils", package: "Location"),
        .product(name: "RoomTestUtils", package: "Rooms"),
      ]),
  ])
