// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Location",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Location",
      targets: ["Location", "LocationTestsUtils", "LocationInteractors"]),
    .library(
      name: "LocationTestsUtils", targets: ["LocationTestsUtils"]),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Location",
      swiftSettings: .defaultSettings),
    .target(
      name: "LocationTestsUtils",
      dependencies: ["Location"],
      swiftSettings: .defaultSettings),
    .target(
      name: "LocationInteractors",
      dependencies: ["Location"],
      swiftSettings: .defaultSettings),
    .testTarget(
      name: "LocationTests",
      dependencies: ["Location", "LocationTestsUtils"],
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
