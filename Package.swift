// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WDDebugTool",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "WDDebugTool",
            targets: ["WDDebugTool"]
        ),
    ],
    targets: [
        .target(
            name: "WDDebugTool",
            path: "WDDebugTool/Classes",
            publicHeadersPath: "."
        ),
    ]
)
