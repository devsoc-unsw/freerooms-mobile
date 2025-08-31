// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Rooms",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "RoomModels", targets: ["RoomModels"]),
    .library(name: "RoomViews", targets: ["RoomViews"]),
    .library(name: "RoomInteractors", targets: ["RoomInteractors"]),
    .library(name: "RoomServices", targets: ["RoomServices"]),
    .library(name: "RoomViewModels", targets: ["RoomViewModels"]),
    .library(name: "RoomTestUtils", targets: ["RoomTestUtils"]),
    .library(name: "Rooms", targets: ["RoomModels", "RoomViews", "RoomInteractors", "RoomServices", "RoomViewModels"]),
  ],
  dependencies: [
    .package(path: "../Networking"),
    .package(path: "../Location"),
    .package(path: "../CommonUI"),
    .package(path: "../Persistence"),
  ],
  targets: [
    .target(
      name: "RoomViews",
      dependencies: [
        "RoomModels",
        .product(name: "CommonUI", package: "CommonUI"),
      ],
      resources: [.process("Resources")]),
    .target(
      name: "RoomViewModels",
      dependencies: [
        "RoomInteractors",
        "RoomModels",
      ]),
    .target(
      name: "RoomInteractors",
      dependencies: [
        "RoomServices",
        .product(name: "Location", package: "Location"),
      ]),
    .target(
      name: "RoomServices",
      dependencies: [
        .product(name: "Networking", package: "Networking"),
        .product(name: "Persistence", package: "Persistence"),
        "RoomModels",
      ]),
    .target(
      name: "RoomModels",
      dependencies: [
        .product(name: "Networking", package: "Networking"),
      ]),
    .target(name: "RoomTestUtils", dependencies: ["Networking", "RoomModels"]),
    .testTarget(
      name: "RoomsTests",
      dependencies: [
        "RoomModels",
        "RoomTestUtils",
        .product(name: "NetworkingTestUtils", package: "Networking"),
        .product(name: "Networking", package: "Networking"),
      ]),
  ])
