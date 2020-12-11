// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PinpointKit",
    platforms: [
        .iOS(.v9),
    ],
    products: [
        .library(
            name: "PinpointKit",
            targets: ["PinpointKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ASLLogger",
            dependencies: [],
            path: "PinpointKit/PinpointKit/Sources/ASLLogger",
            publicHeadersPath: "."
        ),
        .target(
            name: "PinpointKit",
            dependencies: [
                "ASLLogger",
            ],
            path: "PinpointKit/PinpointKit",
            exclude: [
                "Info.plist",
                "Sources/ASLLogger",
                "Sources/Core/ASLLogger.h",
                "Sources/Core/ASLLogger.m",
                "Sources/Core/SourceSansPro-Semibold.ttf",
                "Sources/Core/SourceSansPro-Bold.ttf",
                "Sources/Core/SourceSansPro-Regular.ttf",
            ],
            resources: [
                .copy("Resources/SourceSansPro-Semibold.ttf"),
                .copy("Resources/SourceSansPro-Regular.ttf"),
                .copy("Resources/SourceSansPro-Bold.ttf"),
            ]
        ),
    ]
)
