// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "LurewakeAPI",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(
            url: "https://github.com/vapor/vapor.git",
            exact: "4.122.2"
        )
    ],
    targets: [
        .executableTarget(
            name: "LurewakeAPI",
            dependencies: [
                .product(
                    name: "Vapor",
                    package: "vapor"
                )
            ]
        ),
        .testTarget(
            name: "LurewakeAPITests",
            dependencies: [
                "LurewakeAPI",
                .product(
                    name: "VaporTesting",
                    package: "vapor"
                )
            ]
        )
    ]
)
