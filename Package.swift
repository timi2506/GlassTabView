// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "GlassTabView",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "GlassTabView",
            targets: ["GlassTabView"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GlassTabView",
            dependencies: [],
            path: "Sources/GlassTabView",
            resources: []
        )
    ]
)