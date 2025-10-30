// swift-tools-version: 6.1
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
      name: "Location"),
    .target(
      name: "LocationTestsUtils",
      dependencies: ["Location"]),
    .target(
      name: "LocationInteractors",
      dependencies: ["Location"]),
    .testTarget(
      name: "LocationTests",
      dependencies: ["Location", "LocationTestsUtils"]),
  ])
