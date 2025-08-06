// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Rooms",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "RoomModels", targets: ["RoomModels"]), // Add this product
    .library(name: "RoomViews", targets: ["RoomViews"]), // Add this product
    .library(name: "Rooms", targets: ["RoomViews", "RoomInteractors", "RoomServices", "RoomViewModels"]),
    // Keep combined if needed
  ],
  dependencies: [
    .package(name: "Networking", path: "../Networking"),
    .package(name: "Location", path: "../Location"),
    .package(name: "CommonUI", path: "../CommonUI"),
    .package(name: "Persistence", path: "../Persistence"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
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
    .target(name: "RoomModels", dependencies: ["Persistence"]),
    .testTarget(
      name: "RoomsTests",
      dependencies: [
        "RoomModels",
      ]),
  ])
