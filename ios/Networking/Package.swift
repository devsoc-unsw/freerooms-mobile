// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
// swiftlint:disable trailing_comma

import PackageDescription

let package = Package(
  name: "Networking",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Networking",

      targets: ["Networking"]),
  ],
  dependencies: [
    .package(name: "TestingSupport", path: "../TestingSupport"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Networking"),
    .testTarget(
      name: "NetworkingTests",
      dependencies: ["Networking", "TestingSupport"]),
  ])

// swiftlint:enable trailing_comma
