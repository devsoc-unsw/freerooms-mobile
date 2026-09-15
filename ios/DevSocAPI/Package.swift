// swift-tools-version:6.1

import PackageDescription

let package = Package(
  name: "DevSocAPI",
  platforms: [
    .iOS(.v15),
    .macOS(.v12),
    .tvOS(.v15),
    .watchOS(.v8),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "DevSocAPI", targets: ["DevSocAPI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apollographql/apollo-ios", from: "2.4.0"),
  ],
  targets: [
    .target(
      name: "DevSocAPI",
      dependencies: [
        .product(name: "ApolloAPI", package: "apollo-ios"),
      ],
      path: "./Sources"),
  ],
  swiftLanguageModes: [.v6, .v5])
