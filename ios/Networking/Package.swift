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
    .package(name: "Errors", path: "../Errors"),
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "8.0.0"),
    .package(url: "https://github.com/floormatgen/swift-stdlib-utils", from: "0.3.1"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Networking",
      dependencies: [
        .product(name: "Errors", package: "Errors"),
        .product(name: "VISOR", package: "VISOR"),
        .product(name: "TypeUtils", package: "swift-stdlib-utils"),
      ],
      swiftSettings: .defaultSettings),
    .target(name: "NetworkingTestUtils", dependencies: ["Networking"], swiftSettings: .defaultSettings),
    .testTarget(
      name: "NetworkingTests",
      dependencies: ["Networking", "TestingSupport", "NetworkingTestUtils"],
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
