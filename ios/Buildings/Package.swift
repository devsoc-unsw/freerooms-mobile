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
      targets: ["Buildings", "BuildingViews"]),
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
      name: "Buildings",
      dependencies: ["Location", "Networking", "Persistence", "Rooms"]),
    .target(
      name: "BuildingViews",
      dependencies: ["Buildings", "CommonUI"],
      resources: [.process("Resources")]),
    .testTarget(
      name: "BuildingsTests",
      dependencies: ["Buildings", .product(name: "LocationTestsUtils", package: "Location")]),
  ])
