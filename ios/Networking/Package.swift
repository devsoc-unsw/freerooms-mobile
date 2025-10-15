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
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Networking",
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
