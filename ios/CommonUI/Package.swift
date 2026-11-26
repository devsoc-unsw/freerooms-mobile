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
    .library(
      name: "FreeroomsNavigation",
      targets: ["FreeroomsNavigation"]),
  ],
  dependencies: [
    .package(name: "Rooms", path: "../Rooms"),
    .package(name: "Buildings", path: "../Buildings"),
    .package(name: "Bookings", path: "../Bookings"),
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "13.0.0"),
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
      swiftSettings: swiftSettings),
    .target(
      name: "FreeroomsNavigation",
      dependencies: [
        .product(name: "RoomModels", package: "Rooms"),
        .product(name: "BuildingModels", package: "Buildings"),
        .product(name: "BookingModels", package: "Bookings"),
        .product(name: "VISOR", package: "VISOR"),
      ],
      swiftSettings: swiftSettings),
  ])

// MARK: - Swift Settings

var swiftSettings: [SwiftSetting] {
  [
    .defaultIsolation(nil),
    .strictMemorySafety(),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
  ]
}
