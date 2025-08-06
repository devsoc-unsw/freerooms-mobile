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
  ],
  dependencies: [
    .package(name: "Networking", path: "../Networking"),
    .package(name: "Location", path: "../Location"),
    .package(name: "CommonUI", path: "../CommonUI"),
    .package(name: "Persistence", path: "../Persistence"),
    .package(name: "Rooms", path: "../Rooms"),
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
      dependencies: ["BuildingServices", "Location"]),
    .target(
      name: "BuildingServices",
      dependencies: ["Networking", "Persistence", "BuildingModels"]),
    .target(
      name: "BuildingModels",
      dependencies: ["Persistence", .product(name: "RoomModels", package: "Rooms")]),
    .testTarget(
      name: "BuildingsTests",
      dependencies: [
        "BuildingServices",
        "BuildingInteractors",
        "BuildingModels",
        .product(name: "LocationTestsUtils", package: "Location"),
      ]),
  ])
