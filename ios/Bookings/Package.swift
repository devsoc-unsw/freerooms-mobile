// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Bookings",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    .library(name: "BookingViews", targets: ["BookingViews"]),
  ],
  dependencies: [
    .package(name: "CommonUI", path: "../CommonUI"),
  ],
  targets: [
    .target(
      name: "BookingViews",
      dependencies: [
        .product(name: "CommonUI", package: "CommonUI"),
      ],
      swiftSettings: .defaultSettings),
//        .testTarget(
//            name: "BookingsTests",
//            dependencies: [""]
//        ),
  ],
  swiftLanguageModes: [.v6])

extension [SwiftSetting] {
  static var defaultSettings: [SwiftSetting] {
    [
      .defaultIsolation(MainActor.self),
      .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
      .enableUpcomingFeature("InferIsolatedConformances"),
    ]
  }
}
