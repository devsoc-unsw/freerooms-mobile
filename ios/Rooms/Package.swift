// swift-tools-version: 6.2
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
    .package(name: "TestingSupport", path: "../TestingSupport"),
    .package(name: "Networking", path: "../Networking"),
    .package(name: "Location", path: "../Location"),
    .package(name: "CommonUI", path: "../CommonUI"),
    .package(name: "Persistence", path: "../Persistence"),
    .package(name: "Buildings", path: "../Buildings"),
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "13.0.0"),
  ],
  targets: [
    .target(
      name: "RoomViews",
      dependencies: [
        "RoomModels", "RoomViewModels", "Buildings",
        .product(name: "CommonUI", package: "CommonUI"),
      ],
      resources: [.process("Resources")],
      swiftSettings: swiftSettings),
    .target(
      name: "RoomViewModels",
      dependencies: [
        "RoomInteractors",
        "RoomModels",
        .product(name: "BuildingModels", package: "Buildings"),
      ],
      swiftSettings: swiftSettings),
    .target(
      name: "RoomInteractors",
      dependencies: [
        "RoomServices",
        .product(name: "Location", package: "Location"),
      ],
      swiftSettings: swiftSettings),
    .target(
      name: "RoomServices",
      dependencies: [
        "RoomModels",
        .product(name: "Networking", package: "Networking"),
        .product(name: "Persistence", package: "Persistence"),
        .product(name: "VISOR", package: "VISOR"),
        .product(name: "VISORTestDoubles", package: "VISOR"),
      ],
      resources: [.process("Resources")],
      swiftSettings: swiftSettings),
    .target(
      name: "RoomModels",
      dependencies: [
        .product(name: "Location", package: "Location"),
        .product(name: "Networking", package: "Networking"),
        .product(name: "Persistence", package: "Persistence"),
      ],
      swiftSettings: swiftSettings),
    .target(
      name: "RoomTestUtils",
      dependencies: ["RoomServices", "RoomModels"],
      swiftSettings: swiftSettings),
    .testTarget(
      name: "RoomsTests",
      dependencies: [
        "RoomModels",
        "RoomInteractors",
        "RoomTestUtils",
        "RoomServices",
        "Persistence",
        "TestingSupport",
        .product(name: "Networking", package: "Networking"),
        .product(name: "NetworkingTestUtils", package: "Networking"),
        .product(name: "PersistenceTestUtils", package: "Persistence"),
        .product(name: "Location", package: "Location"),
      ],
      swiftSettings: swiftSettings),
  ],
  swiftLanguageModes: [.v6])

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
