// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Rooms",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Rooms",
      targets: ["Rooms", "RoomViews"]),
  ],
  dependencies: [
    .package(path: "../Networking"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Rooms",
      dependencies: ["Networking"]),
    .target(
      name: "RoomViews",
      dependencies: ["Rooms"]),
    .testTarget(
      name: "RoomsTests",
      dependencies: ["Rooms"]),
  ])
