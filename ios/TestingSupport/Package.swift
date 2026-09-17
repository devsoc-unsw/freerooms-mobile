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
      swiftSettings: swiftSettings),
    .testTarget(
      name: "TestingSupportTests",
      dependencies: ["TestingSupport"],
      swiftSettings: swiftSettings),
  ])

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
