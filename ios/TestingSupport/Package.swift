// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TestingSupport",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "TestingSupport",
      targets: ["TestingSupport"]),
  ],
  dependencies: [
    .package(name: "Persistence", path: "../Persistence"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "TestingSupport",
      dependencies: ["Persistence"],
      swiftSettings: .defaultSettings),
    .testTarget(
      name: "TestingSupportTests",
      dependencies: ["TestingSupport"],
      swiftSettings: .defaultSettings),
  ])

extension [SwiftSetting] {
  static var defaultSettings: [SwiftSetting] {
    [
      .defaultIsolation(MainActor.self),
      .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ]
  }
}
