// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CommonUI",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "CommonUI",
      targets: ["CommonUI"]),
  ],
  dependencies: [
    .package(name: "Rooms", path: "../Rooms"),
    .package(name: "Buildings", path: "../Buildings"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "CommonUI",
      dependencies: [
        .product(name: "BuildingModels", package: "Buildings"),
//        .product(name: "BuildingViewModels", package: "Buildings"),
        .product(name: "RoomModels", package: "Rooms"),
        .product(name: "RoomViewModels", package: "Rooms"),
      ],
      resources: [.process("Resources")],
      swiftSettings: .defaultSettings),
  ])

extension [SwiftSetting] {
  static var defaultSettings: [SwiftSetting] {
    [
      .defaultIsolation(MainActor.self),
      .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
      .enableUpcomingFeature("InferIsolatedConformances"),
    ]
  }
}
