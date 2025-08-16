// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Rooms",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "RoomModels", targets: ["RoomModels"]),
    .library(name: "RoomViews", targets: ["RoomViews"]),
    .library(name: "Rooms", targets: ["RoomViews", "RoomInteractors", "RoomServices", "RoomViewModels", "RoomModels"]),
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
      dependencies: ["RoomModels", "CommonUI"],
      resources: [.process("Resources")]),
    .target(
      name: "RoomViewModels",
      dependencies: ["RoomInteractors", "RoomModels"]),
    .target(
      name: "RoomInteractors",
      dependencies: ["RoomServices", "Location"]),
    .target(
      name: "RoomServices",
      dependencies: ["Networking", "Persistence", "RoomModels"]),
    .target(name: "RoomModels", dependencies: ["Networking"]),
    .testTarget(
      name: "RoomsTests",
      dependencies: [
        "RoomModels",
      ]),
  ])
