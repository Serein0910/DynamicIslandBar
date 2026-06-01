// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DynamicIslandBar",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "DynamicIslandBar",
            resources: [
                .copy("Resources/Info.plist")
            ]
        )
    ]
)