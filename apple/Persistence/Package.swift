// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Persistence",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Persistence",
      targets: ["Persistence"]),
    .library(
      name: "PersistenceTestUtils",
      targets: ["PersistenceTestUtils"]),
  ],
  dependencies: [
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "8.0.0"),
  ],
  targets: [
    .target(
      name: "Persistence",
      dependencies: [.product(name: "VISOR", package: "VISOR")],
      swiftSettings: .defaultSettings),
    .target(
      name: "PersistenceTestUtils",
      dependencies: ["Persistence"],
      swiftSettings: .defaultSettings),
    .testTarget(
      name: "PersistenceTests",
      dependencies: ["Persistence", "PersistenceTestUtils"],
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
