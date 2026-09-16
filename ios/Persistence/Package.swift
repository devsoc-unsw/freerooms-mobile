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
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "13.0.0"),
  ],
  targets: [
    .target(
      name: "Persistence",
      dependencies: [.product(name: "VISOR", package: "VISOR")],
      swiftSettings: swiftSettings),
    .target(
      name: "PersistenceTestUtils",
      dependencies: ["Persistence"],
      swiftSettings: swiftSettings),
    .testTarget(
      name: "PersistenceTests",
      dependencies: ["Persistence", "PersistenceTestUtils"],
      swiftSettings: swiftSettings),
  ],
  swiftLanguageModes: [.v6])

let swiftSettings: [SwiftSetting] = [
  .defaultIsolation(nil),
  .strictMemorySafety(),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
  .enableUpcomingFeature("ImmutableWeakCaptures"),
]
