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
        ),
        .package(
            url: "https://github.com/vapor/fluent.git",
            exact: "4.13.0"
        ),
        .package(
            url: "https://github.com/vapor/fluent-postgres-driver.git",
            exact: "2.12.0"
        ),
        .package(
            url: "https://github.com/apple/swift-crypto.git",
            exact: "4.5.2"
        )
    ],
    targets: [
        .executableTarget(
            name: "LurewakeAPI",
            dependencies: [
                .product(
                    name: "Vapor",
                    package: "vapor"
                ),
                .product(
                    name: "Fluent",
                    package: "fluent"
                ),
                .product(
                    name: "FluentPostgresDriver",
                    package: "fluent-postgres-driver"
                ),
                .product(
                    name: "Crypto",
                    package: "swift-crypto"
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
                ),
                .product(
                    name: "Fluent",
                    package: "fluent"
                ),
                .product(
                    name: "FluentPostgresDriver",
                    package: "fluent-postgres-driver"
                )
            ]
        )
    ]
)
