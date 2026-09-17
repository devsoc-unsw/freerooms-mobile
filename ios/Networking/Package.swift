// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Networking",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Networking",
      targets: ["Networking"]),
    .library(name: "NetworkingTestUtils", targets: ["NetworkingTestUtils"]),
  ],
  dependencies: [
    .package(name: "TestingSupport", path: "../TestingSupport"),
    .package(name: "DevSocAPI", path: "../DevSocAPI"),
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "13.0.0"),
    .package(url: "https://github.com/apollographql/apollo-ios.git", from: "2.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Networking",
      dependencies: [
        .product(name: "VISOR", package: "VISOR"),
        .product(name: "VISORTestDoubles", package: "VISOR"),
        .product(name: "DevSocAPI", package: "DevSocAPI"),
        .product(name: "Apollo", package: "apollo-ios"),
        .product(name: "ApolloSQLite", package: "apollo-ios"),
      ],
      swiftSettings: swiftSettings),
    .target(
      name: "NetworkingTestUtils",
      dependencies: [
        .target(name: "Networking"),
      ],
      swiftSettings: swiftSettings),
    .testTarget(
      name: "NetworkingTests",
      dependencies: [
        "Networking",
        "TestingSupport",
        "NetworkingTestUtils",
      ],
      swiftSettings: swiftSettings),
  ],
  swiftLanguageModes: [.v6])

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
