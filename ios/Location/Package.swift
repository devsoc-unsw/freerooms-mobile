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
      targets: ["Location", "LocationInteractors"]),
  ],
  dependencies: [
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "13.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Location",
      dependencies: [
        .product(name: "VISOR", package: "VISOR"),
        .product(name: "VISORTestDoubles", package: "VISOR"),
      ],
      swiftSettings: swiftSettings),
    .target(
      name: "LocationInteractors",
      dependencies: ["Location"],
      swiftSettings: swiftSettings),
    .testTarget(
      name: "LocationTests",
      dependencies: ["Location"],
      swiftSettings: swiftSettings),
  ])

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
