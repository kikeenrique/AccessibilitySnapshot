// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AccessibilitySnapshot",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .visionOS(.v1),
    ],
    products: [
        // Core + SnapshotTesting for image comparison
        .library(
            name: "AccessibilitySnapshot",
            targets: ["AccessibilitySnapshot"]
        ),
        .library(
            name: "FBSnapshotTestCase-Accessibility",
            targets: [
                "FBSnapshotTestCase-Accessibility",
                "FBSnapshotTestCase-Accessibility-ObjC",
            ]
        ),
        .library(
            name: "AccessibilitySnapshotCore",
            targets: ["AccessibilitySnapshotCore"]
        ),
        .library(
            name: "AccessibilitySnapshotParser",
            targets: ["AccessibilitySnapshotParser"]
        ),
        .library(
            name: "AccessibilitySnapshotPreviews",
            targets: ["AccessibilitySnapshotPreviews"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/uber/ios-snapshot-test-case.git",
            .upToNextMajor(from: "8.0.0")
        ),
        // Resolved to a fork branch rather than a stock release because the `Snapshotting` strategies in
        // `Sources/AccessibilitySnapshot/SnapshotTesting` are vended on visionOS, which requires a
        // swift-snapshot-testing that gates its UIKit image strategies for visionOS as well
        // (pointfreeco/swift-snapshot-testing#1116). Stock releases through 1.19.6 vend them on iOS and tvOS only.
        //
        // A branch requirement makes this package unconsumable by a versioned dependent, so this must be restored to
        // `.upToNextMajor(from: "1.10.0")` before any of this lineage is proposed upstream.
        .package(
            url: "https://github.com/kikeenrique/swift-snapshot-testing.git",
            branch: "dual-vision-mac"
        ),
    ],
    targets: [
        // Compiled directly into this package (rather than referenced with `.package(path:)`) because SwiftPM only
        // supports local package dependencies in root packages, which would prevent consumers from depending on this
        // package using a branch- or revision-based requirement. The sources also remain an independent package at
        // `AccessibilitySnapshotModel/` so its tests can run on any Swift toolchain via `swift test`.
        .target(
            name: "AccessibilitySnapshotModel",
            path: "AccessibilitySnapshotModel/Sources/AccessibilitySnapshotModel"
        ),
        .target(
            name: "AccessibilitySnapshotParser-ObjC",
            path: "Sources/AccessibilitySnapshot/Parser/ObjC"
        ),
        .target(
            name: "AccessibilitySnapshotParser",
            dependencies: [
                "AccessibilitySnapshotModel",
                "AccessibilitySnapshotParser-ObjC",
            ],
            path: "Sources/AccessibilitySnapshot/Parser/Swift",
            resources: [.process("Assets")]
        ),
        .target(
            name: "AccessibilitySnapshotCore",
            dependencies: ["AccessibilitySnapshotParser"],
            path: "Sources/AccessibilitySnapshot/Core",
            resources: [.process("Assets")]
        ),
        .target(
            name: "AccessibilitySnapshotPreviews",
            dependencies: ["AccessibilitySnapshotCore", "AccessibilitySnapshotParser"],
            path: "Sources/AccessibilitySnapshot/AccessibilitySnapshotPreviews"
        ),
        .target(
            name: "AccessibilitySnapshot",
            dependencies: [
                "AccessibilitySnapshotCore",
                "AccessibilitySnapshotParser-ObjC",
                "AccessibilitySnapshotPreviews",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "Sources/AccessibilitySnapshot/SnapshotTesting"
        ),
        .target(
            name: "FBSnapshotTestCase-Accessibility",
            dependencies: [
                "AccessibilitySnapshotCore",
                "AccessibilitySnapshotParser-ObjC",
                "AccessibilitySnapshotPreviews",
                .product(name: "iOSSnapshotTestCase", package: "ios-snapshot-test-case"),
            ],
            path: "Sources/AccessibilitySnapshot/iOSSnapshotTestCase/Swift"
        ),
        .target(
            name: "FBSnapshotTestCase-Accessibility-ObjC",
            dependencies: [
                "AccessibilitySnapshotCore",
                .product(name: "iOSSnapshotTestCase", package: "ios-snapshot-test-case"),
                "FBSnapshotTestCase-Accessibility",
            ],
            path: "Sources/AccessibilitySnapshot/iOSSnapshotTestCase/ObjC"
        ),
    ]
)
