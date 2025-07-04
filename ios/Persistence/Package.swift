// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Persistence",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Persistence",
      targets: ["Persistence"]),
  ],
  dependencies: [
    // Empty array - persistence layer should be feature-agnostic
  ],
  targets: [
    .target(
      name: "Persistence",
      dependencies: []),
    .testTarget(
      name: "PersistenceTests",
      dependencies: ["Persistence"]),
  ])
