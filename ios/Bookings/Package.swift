// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "Bookings",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Bookings",
      targets: [
        "BookingModels",
        "BookingServices",
        "BookingInteractors",
        "BookingViewModels",
        "BookingViews",
      ]),
    .library(name: "BookingModels", targets: ["BookingModels"]),
    .library(name: "BookingServices", targets: ["BookingServices"]),
    .library(name: "BookingInteractors", targets: ["BookingInteractors"]),
    .library(name: "BookingViewModels", targets: ["BookingViewModels"]),
    .library(name: "BookingViews", targets: ["BookingViews"]),
    .library(name: "BookingTestUtils", targets: ["BookingTestUtils"]),
  ],
  dependencies: [
    .package(name: "CommonUI", path: "../CommonUI"),
    .package(name: "DevSocAPI", path: "../DevSocAPI"),
    .package(name: "Networking", path: "../Networking"),
    .package(name: "Rooms", path: "../Rooms"),
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "8.0.0"),
    .package(url: "https://github.com/apollographql/apollo-ios.git", exact: "2.1.2"),
  ],
  targets: [
    .target(
      name: "BookingModels",
      swiftSettings: .defaultSettings),
    .target(
      name: "BookingServices",
      dependencies: [
        "BookingModels",
        .product(name: "DevSocAPI", package: "DevSocAPI"),
        .product(name: "Apollo", package: "apollo-ios"),
        .product(name: "ApolloAPI", package: "apollo-ios"),
        .product(name: "VISOR", package: "VISOR"),
      ],
      swiftSettings: .defaultSettings),
    .target(
      name: "BookingInteractors",
      dependencies: [
        "BookingModels",
        "BookingServices",
        .product(name: "VISOR", package: "VISOR"),
      ],
      swiftSettings: .defaultSettings),
    .target(
      name: "BookingViewModels",
      dependencies: ["BookingModels", "BookingServices", "BookingInteractors"],
      swiftSettings: .defaultSettings),
    .target(
      name: "BookingViews",
      dependencies: [
        "BookingModels",
        "BookingViewModels",
        .product(name: "CommonUI", package: "CommonUI"),
        .product(name: "RoomViews", package: "Rooms"),
      ],
      swiftSettings: .defaultSettings),
    .target(
      name: "BookingTestUtils",
      dependencies: ["BookingModels"],
      swiftSettings: .defaultSettings),
    .testTarget(
      name: "BookingsTests",
      dependencies: [
        "BookingModels",
        "BookingServices",
        "BookingInteractors",
        "BookingViewModels",
        "BookingViews",
        "BookingTestUtils",
        .product(name: "DevSocAPI", package: "DevSocAPI"),
        .product(name: "NetworkingTestUtils", package: "Networking"),
        .product(name: "Apollo", package: "apollo-ios"),
      ],
      swiftSettings: .defaultSettings),
  ],
  swiftLanguageModes: [.v6])

extension [SwiftSetting] {
  static var defaultSettings: [SwiftSetting] {
    [
      .defaultIsolation(MainActor.self),
      .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
      .enableUpcomingFeature("InferIsolatedConformances"),
    ]
  }
}
