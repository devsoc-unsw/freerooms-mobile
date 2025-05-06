// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "DB",
  products: [
    .library(
      name: "DB",
      targets: ["DB"]),
  ],
  dependencies: [
    .package(path: "../Buildings"),
  ],
  targets: [
    .target(
      name: "DB",
      dependencies: ["Buildings"])
      .testTarget(
        name: "DBTests",
        dependencies: ["DB"]),
  ])
