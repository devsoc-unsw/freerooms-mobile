// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable trailing_comma

import PackageDescription

let package = Package(
  name: "Buildings",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Buildings",
      targets: ["Buildings"]),
  ],
  dependencies: [
    .package(name: "Location", path: "../Location"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Buildings",
    dependencies: ["Location"]),
    .testTarget(
      name: "BuildingsTests",
      dependencies: ["Buildings"]),
  ])

// swiftlint:enable trailing_comma
