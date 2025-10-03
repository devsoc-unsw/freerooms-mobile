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
  targets: [
    .target(
      name: "Persistence",
      swiftSettings: .defaultSettings),
    .target(name: "PersistenceTestUtils", dependencies: ["Persistence"]),
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
