// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "FreeroomsIntents",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .macCatalyst(.v17),
    .visionOS(.v1),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "FreeroomsIntents",
      targets: ["FreeroomsIntents"]),
  ],
  dependencies: [
    .package(name: "CommonUI", path: "../CommonUI"),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", "602.0.0"..<"605.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "FreeroomsIntents",
      dependencies: [
        .target(name: "FreeroomsIntentsMacros"),
        .product(name: "CommonUI", package: "CommonUI"),
      ],
      swiftSettings: swiftSettings),
    .macro(
      name: "FreeroomsIntentsMacros",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
      ],
      swiftSettings: swiftSettings),
  ],
  swiftLanguageModes: [.v6])

// MARK: - Swift Settings

let swiftSettings: [SwiftSetting] = [
  .defaultIsolation(nil),
  .strictMemorySafety(),
  .enableUpcomingFeature("ExistentialAny"),
  .enableUpcomingFeature("InternalImportsByDefault"),
  .enableUpcomingFeature("MemberImportVisibility"),
  .enableUpcomingFeature("InferIsolatedConformances"),
  .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]
