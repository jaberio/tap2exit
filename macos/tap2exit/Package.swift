// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
    name: "tap2exit",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "tap2exit", targets: ["tap2exit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "tap2exit",
            dependencies: [],
            resources: [
                // If your plugin requires a privacy manifest, uncomment:
                // .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
